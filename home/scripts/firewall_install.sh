#!/bin/bash

# Définition des variables
NFTABLES_CONF="/etc/nftables.conf"
NFTABLES_LOG="/var/log/nftables.log"
JOURNALD_CONF="/etc/systemd/journald.conf"
SERVICE_FILE="/etc/systemd/system/nftables-journald.service"
LOG_SERVICE="False"

# Fonction pour gérer les erreurs
handle_error() {
    echo "Erreur : $1" >&2
    exit 1
}

# Vérification que sudo est disponible
if ! command -v sudo &> /dev/null; then
    handle_error "sudo n'est pas installé. Veuillez l'installer pour continuer."
fi

# Vérification et installation de nftables
echo "Vérification des dépendances..."
if ! command -v nft &> /dev/null; then
    if command -v yay &> /dev/null; then
        yay -S --noconfirm nftables || handle_error "Installation de nftables échouée"
    else
        handle_error "yay n'est pas installé. Veuillez installer yay ou nftables manuellement"
    fi
fi

sudo groupadd nftables
sudo usermod -aG nftables $USER

# Créer un fichier temporaire pour les règles
temp_rules=$(mktemp)
trap 'rm -f "$temp_rules"' EXIT

# Configuration des règles nftables
cat << 'EOF' > "$temp_rules"
#!/usr/sbin/nft -f

flush ruleset

# Création de la table et des chaînes
add table inet firewall
add chain inet firewall input { type filter hook input priority 0 ; policy drop ; }
add chain inet firewall output { type filter hook output priority 0 ; policy accept ; }
add chain inet firewall forward { type filter hook forward priority 0 ; policy drop ; }

# Règles de base pour la chaîne input
add rule inet firewall input ct state established,related accept
add rule inet firewall input ct state invalid drop
add rule inet firewall input iif lo accept

# Protection contre les attaques TCP de base
add rule inet firewall input tcp flags & (fin|syn) == fin|syn drop
add rule inet firewall input tcp flags & (syn|rst) == syn|rst drop
add rule inet firewall input tcp flags & (fin|syn|rst|psh|ack|urg) < fin drop
add rule inet firewall input tcp flags & fin != 0 ct state new drop

# Protection DoS/DDoS
add rule inet firewall input tcp flags syn tcp dport {80, 443} limit rate 30/minute accept
add rule inet firewall input tcp flags syn limit rate 20/second burst 50 packets accept
add rule inet firewall input udp dport 0-65535 limit rate 100/second burst 100 packets accept
add rule inet firewall input icmp type echo-request limit rate 10/second accept

# Protection contre le scan de ports
add rule inet firewall input tcp flags syn tcp dport 0-19 drop
add rule inet firewall input tcp flags syn tcp dport 137-139 drop
add rule inet firewall input tcp flags syn ct state new limit rate 10/second accept

# Protection contre les paquets fragmentés
# Bloque tous les paquets fragmenté
# add rule inet firewall input ip frag-off & 1 == 1 drop
# add rule inet firewall input ip frag-off & 8191 != 0 drop
# Bloque les paquets fragmentés sauf ceux venant de l'interface VPN (tun0) :
# add rule inet firewall input iif != "tun0" ip frag-off & 1 == 1 drop
# add rule inet firewall input iif != "tun0" ip frag-off & 8191 != 0 drop
# Accepte les fragments de paquets, mais limite le taux
add rule inet firewall input ip frag-off & 1 == 1 limit rate 10/second accept
add rule inet firewall input ip frag-off & 8191 != 0 limit rate 10/second accept


# Protection anti-spoofing
add rule inet firewall input ip saddr 127.0.0.0/8 iif != "lo" drop
add rule inet firewall input ip saddr 0.0.0.0/8 drop
add rule inet firewall input ip saddr 169.254.0.0/16 drop
add rule inet firewall input ip saddr 224.0.0.0/4 drop

# Protection contre les scans furtifs
add rule inet firewall input tcp flags & (fin|syn|rst|ack) == 0 drop
add rule inet firewall input tcp flags & (fin|syn|rst|psh|ack|urg) == fin|psh|urg drop

# Protection contre les attaques par amplification
add rule inet firewall input udp dport 17 drop
add rule inet firewall input udp dport 19 drop
add rule inet firewall input udp dport 123 drop
add rule inet firewall input udp dport 161 drop
add rule inet firewall input udp dport 1900 drop
add rule inet firewall input udp dport 11211 drop

# Protection des services sensibles
add rule inet firewall input tcp dport 22 ct state new limit rate 5/minute accept
add rule inet firewall input tcp dport { 3306, 5432 } drop

# Logging et rejet final
add rule inet firewall input log prefix "nft-drop: " level debug flags all
add rule inet firewall input counter drop
EOF

# Application des règles avec sudo
echo "Application des règles nftables..."
if ! sudo nft -f "$temp_rules"; then
    handle_error "Application des règles nftables échouée"
fi

# Vérification de l'application des règles
if ! sudo nft list ruleset | grep -q "nft-drop:"; then
    handle_error "Les règles n'ont pas été appliquées correctement"
fi

# Sauvegarde de la configuration
sudo nft list ruleset | sudo tee "$NFTABLES_CONF" > /dev/null

# Créer le fichier de log
sudo touch $NFTABLES_LOG

# Changer le propriétaire du fichier (root: nftables)
sudo chown root:nftables $NFTABLES_LOG

# Modifier les permissions pour que seul root puisse modifier le fichier, et les membres du groupe nftables puissent lire
sudo chmod 640 $NFTABLES_LOG

# Configuration de journald
echo "Configuration de journald..."
cat << EOF | sudo tee "$JOURNALD_CONF" > /dev/null
[Journal]
SystemMaxUse=100M
SystemMaxFileSize=100M
SystemMaxFiles=4
Storage=persistent
Compress=yes
ForwardToSyslog=yes
EOF

if [[ "$LOG_SERVICE" == "True" ]]; then

    # Configuration du service systemd
    cat << EOF | sudo tee "$SERVICE_FILE" > /dev/null
[Unit]
Description=Règles de pare-feu nftables avec journald
After=network.target
Wants=network.target

[Service]
Type=simple
ExecStartPre=/usr/sbin/nft -f /etc/nftables.conf
ExecStart=/usr/bin/journalctl -f -n 0 -o cat -t kernel | /usr/bin/grep --line-buffered "nft-drop:"
Restart=always
RestartSec=30
StandardOutput=journal
StandardError=journal
SyslogIdentifier=nftables-log

[Install]
WantedBy=multi-user.target
EOF

    # Ajout de la tâche cron pour journaliser périodiquement
    echo "Création de la tâche cron pour la collecte des logs toutes les 5 minutes..."
    (crontab -l 2>/dev/null; echo "*/5 * * * * /usr/bin/journalctl -n 100 -o short -t nftables-log > $NFTABLES_LOG") | sudo crontab -

    # Vérification du statut des services
    sudo systemctl daemon-reload      
    sudo systemctl enable --now nftables.service
    sudo systemctl enable --now cronie.service
    sudo systemctl enable --now nftables-journald.service

else

    sudo systemctl daemon-reload      
    sudo systemctl enable --now nftables.service

fi

sudo truncate -s 0 /var/log/nftables.log
sudo nft list ruleset

echo "Configuration du pare-feu terminée avec succès"






