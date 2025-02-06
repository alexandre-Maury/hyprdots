#!/bin/bash

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

# Récupérer les informations du CPU
case "$1" in
    --popup)
        # Afficher une notification détaillée
        cpu_usage=$(get_cpu_usage)
        cpu_temp=$(sensors | awk '/Tctl:/ {print $2}' | sed 's/+//;s/°C//')
        
        notify-send -u low -a System -i /usr/share/icons/gnome/48x48/devices/cpu.png "CPU Stats :" \
        "CPU Usage: $cpu_usage%\nCPU Temp: $cpu_temp°C"
        ;;
    *)
        # Récupérer les données en temps réel
        cpu_usage=$(get_cpu_usage)
        cpu_temp=$(sensors | awk '/Tctl:/ {print $2}' | sed 's/+//;s/°C//')

        # Afficher les résultats avec des icônes
        printf "  %s%% - %s°C\n" \
            "$cpu_usage" \
            "$cpu_temp"
        ;;
esac