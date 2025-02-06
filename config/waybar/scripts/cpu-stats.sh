#!/bin/bash

# Fonction pour créer un graphique de barres
create_graph() {
    local value=$1
    local max=$2
    local icons=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")
    local index=$(( (value * ${#icons[@]}) / max ))
    index=$(( index > ${#icons[@]} - 1 ? ${#icons[@]} - 1 : index ))  # Limiter à l'index maximum
    echo "${icons[$index]}"
}

# Fonction pour calculer l'utilisation du CPU
get_cpu_usage() {
    # Lire la première ligne de /proc/stat
    read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat

    # Calculer les totaux
    total=$((user + nice + system + idle + iowait + irq + softirq + steal + guest + guest_nice))
    idle_total=$((idle + iowait))

    # Attendre 1 seconde
    sleep 1

    # Lire à nouveau /proc/stat
    read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat

    # Calculer les nouveaux totaux
    total_new=$((user + nice + system + idle + iowait + irq + softirq + steal + guest + guest_nice))
    idle_total_new=$((idle + iowait))

    # Calculer l'utilisation du CPU
    total_diff=$((total_new - total))
    idle_diff=$((idle_total_new - idle_total))
    cpu_usage=$((100 * (total_diff - idle_diff) / total_diff))

    echo "$cpu_usage"
}

# Fonction pour obtenir le nombre de cœurs physiques et logiques
get_cpu_cores() {
    physical_cores=$(grep "cpu cores" /proc/cpuinfo | uniq | awk '{print $4}')
    logical_cores=$(nproc)
    echo "${physical_cores}/${logical_cores} (Cores/Threads)"
}

# Fonction pour obtenir la fréquence actuelle du CPU en GHz
get_cpu_frequency() {
    # Récupérer la fréquence actuelle du premier core (en MHz)
    frequency_mhz=$(awk -F ': ' '/cpu MHz/ {print $2; exit}' /proc/cpuinfo)
    
    # Convertir en GHz avec une décimale
    frequency_ghz=$(echo "scale=1; $frequency_mhz / 1000" | bc)
    
    echo "$frequency_ghz GHz"
}

# Récupérer les informations du CPU
case "$1" in
    --popup)
        # Afficher une notification détaillée
        cpu_usage=$(get_cpu_usage)
        cpu_temp=$(sensors | awk '/Tctl:/ {print $2}' | sed 's/+//;s/°C//')
        cpu_cores=$(get_cpu_cores)
        cpu_frequency=$(get_cpu_frequency)
        
        notify-send -u low -a System -i /usr/share/icons/gnome/48x48/devices/cpu.png "CPU Stats :" \
        "CPU Usage: $cpu_usage%\nCPU Temp: $cpu_temp°C\n$cpu_cores\nFrequency: $cpu_frequency"
        ;;
    *)
        # Récupérer les données en temps réel
        cpu_usage=$(get_cpu_usage)
        cpu_temp=$(sensors | awk '/Tctl:/ {print $2}' | sed 's/+//;s/°C//')
        cpu_cores=$(get_cpu_cores)
        cpu_frequency=$(get_cpu_frequency)

        # Créer un graphique de barres pour l'utilisation du CPU
        cpu_graph=$(create_graph "$cpu_usage" 100)

        # Afficher les résultats avec des icônes et le graphique
        printf "  %s%% - %s°C | %s | %s %s\n" \
            "$cpu_usage" \
            "$cpu_temp" \
            "$cpu_cores" \
            "$cpu_frequency" \
            "$cpu_graph"
        ;;
esac