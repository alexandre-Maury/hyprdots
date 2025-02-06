#!/bin/bash

# Fonction pour obtenir l'utilisation du disque dur
get_disk_usage() {
    # Récupérer l'utilisation du disque dur pour la partition racine (/)
    disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    disk_total=$(df -h / | awk 'NR==2 {print $2}')
    disk_used=$(df -h / | awk 'NR==2 {print $3}')
    disk_available=$(df -h / | awk 'NR==2 {print $4}')

    echo "$disk_usage,$disk_total,$disk_used,$disk_available"
}

# Récupérer les informations du disque dur
case "$1" in
    --popup)
        # Afficher une notification détaillée
        IFS=, read -r disk_usage disk_total disk_used disk_available < <(get_disk_usage)
        
        notify-send -u low -a System -i /usr/share/icons/gnome/48x48/devices/drive-harddisk.png "Disk Stats :" \
        "Disk Usage: $disk_usage%\nTotal: $disk_total\nUsed: $disk_used\nAvailable: $disk_available"
        ;;
    *)
        # Récupérer les données en temps réel
        IFS=, read -r disk_usage disk_total disk_used disk_available < <(get_disk_usage)

        # Afficher les résultats avec des icônes
        printf "  %s%%   %s/%s (Free: %s)\n" \
            "$disk_usage" \
            "$disk_used" \
            "$disk_total" \
            "$disk_available"
        ;;
esac
