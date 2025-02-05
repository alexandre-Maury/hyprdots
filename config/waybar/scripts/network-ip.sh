#!/bin/bash

# Variables
option="$1"  # Récupère l'option passée au script (--status ou --network)
active_iface=""  # Interface active
active_ip=""  # Adresse IP de l'interface active
found_connection=false  # Indicateur de connexion trouvée
public_ip="x.x.x.x"  # Adresse IP publique (valeur par défaut)

# Fonction pour vérifier la connectivité Internet
check_internet() {
    ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1
    return $?
}

# Récupérer l'interface active et son adresse IP
get_active_interface() {
    # Utiliser `ip route` pour trouver l'interface par défaut
    active_iface=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5}')
    if [[ -n "$active_iface" ]]; then
        active_ip=$(ip -4 addr show "$active_iface" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
        if [[ -n "$active_ip" ]]; then
            found_connection=true
        fi
    fi
}

# Récupérer l'adresse IP publique
get_public_ip() {
    if check_internet; then
        public_ip=$(curl -s --max-time 3 https://api.ipify.org || echo "x.x.x.x")
    fi
}

# Traiter l'option passée au script
case "$option" in
    "status")
        get_active_interface
        if [[ "$found_connection" == true ]]; then
            if [[ "$active_iface" =~ ^wlan|^wlp ]]; then
                # Si l'interface est Wi-Fi, récupérer le SSID
                ssid=$(iw dev "$active_iface" link 2>/dev/null | grep -Eo "SSID: .+" | sed 's/SSID: //')
                signal=$(iw dev "$active_iface" link 2>/dev/null | grep -Eo "signal: .+" | sed 's/signal: //')
                echo "   $ssid  ($signal)"  # Affiche le SSID et la force du signal
            else
                # Sinon, afficher l'interface Ethernet
                echo "   $active_iface"
            fi
        else
            echo ""  # Affiche une icône d'avertissement si aucune connexion n'est trouvée
        fi
        ;;

    "network")
        get_active_interface
        get_public_ip
        if [[ "$found_connection" == true ]]; then
            echo "  $active_ip  |     $public_ip"  # Affiche l'adresse IP locale et publique
        else
            echo "x.x.x.x | $public_ip"  # Affiche des valeurs par défaut
        fi
        ;;

    *)
        # Afficher l'utilisation correcte du script si l'option est invalide
        echo "Usage : $0 --status | --network"
        exit 1
        ;;
esac