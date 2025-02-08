#!/bin/bash

# Cette configuration vous permettra de suivre facilement les paquets abandonnés 
# et d'éviter que votre fichier journal ne devienne trop volumineux. 
# Vous pourrez consulter les logs en temps réel à l'aide de la commande suivante :
# sudo tail -f /var/log/nftables.log

# Fonction pour installer nftables et configurer le pare-feu
install_nftables() {

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
    sudo nft -f "$temp_rules"

    # Sauvegarder la configuration
    sudo nft list ruleset | sudo tee /etc/nftables.conf > /dev/null

    # Nettoyer le fichier temporaire
    rm -f "$temp_rules"


    # Créer la configuration de rsyslog pour nftables
    echo ":msg, startswith, \"nft drop\" -/var/log/nftables.log\n& stop" | sudo tee /etc/rsyslog.d/nftables.conf 

    echo "/var/log/nftables.log {
        size +10M
        maxage 30
        sharedscripts
        postrotate
            /usr/bin/systemctl kill -s HUP rsyslog.service >/dev/null 2>&1 || true
        endscript
    }" | sudo tee /etc/logrotate.d/nftables 

    echo "Configuration du pare-feu nftables terminée."

    # Activer et démarrer les services nftables et rsyslog
    sudo systemctl enable nftables.service
    sudo systemctl enable rsyslog.service
}

install_nftables

echo "Installation et configuration terminées !"

