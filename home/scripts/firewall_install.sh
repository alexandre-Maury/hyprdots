#!/bin/bash

# Créer un fichier temporaire pour les règles
temp_rules=$(mktemp)

echo "Installation de nftables..."

# Installer nftables (utilisez yay pour Arch Linux)
if ! command -v yay &> /dev/null; then
    echo "Erreur : yay n'est pas installé. Veuillez installer yay pour continuer."
    exit 1
fi
yay -S --noconfirm nftables

# Supprimer la table firewall existante pour éviter les doublons
echo "Suppression de la table firewall existante..."
sudo nft delete table inet firewall 2>/dev/null || true

# Écrire les règles dans le fichier temporaire
cat << 'EOF' > "$temp_rules"
flush ruleset

add table inet firewall
add chain inet firewall input { type filter hook input priority 0 ; policy drop ; }
add chain inet firewall output { type filter hook output priority 0 ; policy accept ; }
add chain inet firewall forward { type filter hook forward priority 0 ; policy drop ; }

add rule inet firewall input ct state established,related accept
add rule inet firewall input ct state invalid drop
add rule inet firewall input iif lo accept

add rule inet firewall input ip protocol icmp accept
add rule inet firewall input ip6 nexthdr icmpv6 accept

add rule inet firewall input log prefix "nft-drop: " level debug
add rule inet firewall input counter reject with icmpx type admin-prohibited
EOF

# Appliquer les règles avec sudo
if ! sudo nft -f "$temp_rules"; then
    echo "Erreur lors de l'application des règles nftables."
    rm -f "$temp_rules"
    exit 1
fi

# Vérifier que les règles ont été appliquées
if ! sudo nft list ruleset | grep -q "nft-drop:"; then
    echo "Erreur : Les règles nftables n'ont pas été appliquées correctement."
    rm -f "$temp_rules"
    exit 1
fi

# Sauvegarder la configuration
sudo nft list ruleset | sudo tee /etc/nftables.conf > /dev/null

# Nettoyer le fichier temporaire
rm -f "$temp_rules"

echo "Configuration du pare-feu nftables terminée."

# Créer un fichier de service systemd pour nftables (en utilisant journald)
echo "[Unit]
Description=Règles de pare-feu nftables avec journald
After=network.target

[Service]
ExecStartPre=/usr/sbin/nft -f /etc/nftables.conf
ExecStart=$HOME/scripts/nftables-log-watcher.sh
Restart=always
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=nftables-log

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/nftables-journald.service > /dev/null

# Activer et démarrer le service systemd
sudo systemctl daemon-reload
sudo systemctl enable --now nftables-journald.service

echo "Le pare-feu nftables est configuré pour utiliser journald pour les logs."

# Activer et démarrer le service nftables
sudo systemctl enable --now nftables.service

echo "Le pare-feu nftables a été configuré avec succès avec journald."

# Configurer logrotate pour gérer la taille des logs générés par journald
echo "/var/log/journal/*/*/system.journal {
    size 100M
    rotate 4
    compress
    delaycompress
    missingok
    notifempty
    postrotate
        /usr/bin/systemctl kill -s HUP systemd-journald.service >/dev/null 2>&1 || true
    endscript
}" | sudo tee /etc/logrotate.d/journald > /dev/null

echo "Logrotate a été configuré pour gérer les logs journald."