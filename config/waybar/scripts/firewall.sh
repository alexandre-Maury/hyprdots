#!/bin/bash

# Fonction pour vérifier l'état de nftables
check_nft_status() {
    if sudo nft list ruleset | grep -q "table inet firewall"; then
        echo "active"
    else
        echo "inactive"
    fi
}

# Fonction pour activer nftables
enable_nftables() {

    # Créer un fichier temporaire pour les règles
    temp_rules=$(mktemp)

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

}

# Fonction pour désactiver nftables
disable_nftables() {
    #sudo nft flush ruleset
    echo "flush ruleset" | sudo nft -f -
}

# Vérifier l'état actuel de nftables
NF_STATUS=$(check_nft_status)

# Traiter l'option passée au script
case "$1" in
    "--toggle")
        if [ "$NF_STATUS" == "active" ]; then
            disable_nftables
        else
            enable_nftables
        fi
        # Mettre à jour l'état après le basculement
        NF_STATUS=$(check_nft_status)
        ;;
esac

# Afficher l'icône et l'état avec la couleur correspondante
if [ "$NF_STATUS" == "active" ]; then
    printf "<span color=\"#32CD32\"> Firewall: Actif</span>\n"  # Vert pour actif
else
    # printf " Firewall: Inactif\n"  # Bouclier rouge
    printf "<span color=\"#FF6347\"> Firewall: Inactif</span>\n"  # Bouclier rouge pour inactif
fi