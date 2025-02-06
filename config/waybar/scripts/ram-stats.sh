#!/bin/bash

# Fonction pour créer un graphique de barres avec des icônes Nerd Fonts
create_graph() {
    local value=$1
    local max=$2
    local icons=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")
    local index=$(( (value * 8) / max ))
    index=$(( index > 7 ? 7 : index ))  # Limiter à l'index maximum
    echo "${icons[$index]}"
}

# Fonction pour formater la mémoire
format_memory() {
    local mem=$1
    if (( mem > 1024 )); then
        echo "$(( mem / 1024 ))G"
    else
        echo "${mem}M"
    fi
}

# Récupérer les informations de la RAM
case "$1" in
    --popup)
        # Afficher une notification détaillée
        mem_usage=$(free -m | awk '/Mem:/ {print $3}')
        mem_total=$(free -m | awk '/Mem:/ {print $2}')
        mem_percent=$(( mem_usage * 100 / mem_total ))
        
        notify-send -u low -a System -i /usr/share/icons/gnome/48x48/devices/computer.png "RAM Stats :" \
        "Memory Usage: $mem_usage MB ($mem_percent%)\nTotal Memory: $mem_total MB"
        ;;
    *)
        # Récupérer les données en temps réel
        mem_usage=$(free -m | awk '/Mem:/ {print $3}')
        mem_total=$(free -m | awk '/Mem:/ {print $2}')
        mem_percent=$(( mem_usage * 100 / mem_total ))

        # Formater l'utilisation et la capacité totale
        mem_usage_formatted=$(format_memory "$mem_usage")
        mem_total_formatted=$(format_memory "$mem_total")

        # Créer des graphiques avec des icônes Nerd Fonts
        mem_graph=$(create_graph "$mem_percent" 100)

        # Afficher les résultats avec des icônes Nerd Fonts
        printf "  %s/%s (%s%%) %s\n" \
            "$mem_usage_formatted" \
            "$mem_total_formatted" \
            "$mem_percent" \
            "$mem_graph"
        ;;
esac