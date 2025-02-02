#!/bin/bash

option="$1"
wifi_iface=""
wifi_info=""
wifi_ip=""
wifi_signal=""
ethernet_iface=""
ethernet_ip=""
found_connection=false
public_ip=""

# Récupérer les interfaces réseau
interfaces=$(ip -o link show | awk -F': ' '{print $2}')

for iface in $interfaces; do
    # Ignorer l'interface loopback
    [[ "$iface" == "lo" ]] && continue

    # Récupérer l'adresse IP de l'interface
    ip_address=$(ip -4 addr show "$iface" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

    if [[ -n "$ip_address" ]]; then
        found_connection=true
        if [[ "$iface" =~ ^wlan[0-9]+$ ]]; then
            wifi_iface=$iface
            wifi_ip=$ip_address
            wifi_info=$(iw dev "$iface" link | awk -F': ' '/SSID/ {print $2}')
            wifi_signal=$(iw dev "$iface" link | awk -F': ' '/signal/ {print $2}')
        else
            ethernet_iface=$iface
            ethernet_ip=$ip_address
        fi
    fi
done

# Traiter l'option
case "$option" in
    "--status")
        if [[ "$found_connection" == true ]]; then
            if [[ -n "$wifi_ip" ]]; then
                echo "${wifi_info:-Inconnu} (${wifi_signal:-N/A} dBm)"
            elif [[ -n "$ethernet_ip" ]]; then
                echo "$ethernet_iface"

            fi
        else
            echo "N/A"
        fi
        ;;
        
    "--network")
        if [[ "$found_connection" == true ]]; then
        
            public_ip=$(curl -s --max-time 2 https://api.ipify.org || echo "N/A")

            if [[ -n "$wifi_ip" ]]; then
                local_ip=$wifi_ip
            elif [[ -n "$ethernet_ip" ]]; then
                local_ip=$ethernet_ip
            fi

            echo "$local_ip | $public_ip"
        else
            echo "x.x.x.x | x.x.x.x"
        fi
        ;;
        
    *)
        echo "Usage : $0 --status | --network"
        exit 1
        ;;
esac
