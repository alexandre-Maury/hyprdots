#!/bin/bash

# Créer un fichier temporaire pour les règles
temp_rules=$(mktemp)

echo "Installation de nftables et rsyslog..."

# Installer nftables et rsyslog 
yay -S --noconfirm nftables rsyslog

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

# Sauvegarder la configuration
sudo nft list ruleset | sudo tee /etc/nftables.conf > /dev/null

# Nettoyer le fichier temporaire
rm -f "$temp_rules"

# Créer le répertoire /etc/rsyslog.d/ s'il n'existe pas
if [ ! -d "/etc/rsyslog.d" ]; then
    echo "Création du répertoire /etc/rsyslog.d..."
    sudo mkdir -p /etc/rsyslog.d
fi

# Créer la configuration de rsyslog pour nftables
echo ':msg, startswith, "nft-drop:" -/var/log/nftables.log
& stop' | sudo tee /etc/rsyslog.d/nftables.conf > /dev/null

# Créer le fichier de log et définir les permissions
sudo touch /var/log/nftables.log

# Vérifier l'existence de l'utilisateur et du groupe 'syslog'
if ! getent passwd syslog &>/dev/null || ! getent group syslog &>/dev/null; then
    echo "L'utilisateur ou le groupe 'syslog' n'existe pas, création en cours..."
    sudo useradd -r -s /bin/false syslog
    sudo groupadd syslog
fi

# Changer le propriétaire du fichier de log
sudo chown syslog:syslog /var/log/nftables.log

# Définir les bonnes permissions
sudo chmod 640 /var/log/nftables.log

# Configurer logrotate pour nftables.log
echo "/var/log/nftables.log {
    size 10M
    rotate 4
    missingok
    notifempty
    compress
    delaycompress
    sharedscripts
    postrotate
        /usr/bin/systemctl kill -s HUP rsyslog.service >/dev/null 2>&1 || true
    endscript
}" | sudo tee /etc/logrotate.d/nftables > /dev/null

echo "Configuration du pare-feu nftables terminée."

# Activer et démarrer les services nftables et rsyslog
sudo systemctl enable --now nftables.service
sudo systemctl enable --now rsyslog.service

echo "Le pare-feu nftables et rsyslog ont été configurés avec succès."
