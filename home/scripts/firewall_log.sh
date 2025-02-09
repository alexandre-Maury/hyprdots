#!/bin/bash

show_help() {
    echo "Usage: $0 [option]"
    echo "Options:"
    echo "  -l, --live       Afficher les logs en temps réel"
    echo "  -t, --today      Afficher les logs d'aujourd'hui"
    echo "  -h, --hour       Afficher les logs de la dernière heure"
    echo "  -s, --stats      Afficher les statistiques des rejets"
    echo "  --help           Afficher cette aide"
}

case "$1" in
    -l|--live)
        echo "Affichage des logs en temps réel (Ctrl+C pour quitter):"
        journalctl -f -t kernel | grep --color=auto "nft-drop"
        ;;
    -t|--today)
        echo "Logs d'aujourd'hui:"
        journalctl -t kernel --since today | grep "nft-drop" | \
        awk '{print $1,$2,$3,$4,$5}' | sort | uniq -c | sort -nr
        ;;
    -h|--hour)
        echo "Logs de la dernière heure:"
        journalctl -t kernel --since "1 hour ago" | grep "nft-drop" | \
        awk '{print $1,$2,$3,$4,$5}' | sort | uniq -c | sort -nr
        ;;
    -s|--stats)
        echo "Statistiques des rejets:"
        echo "------------------------"
        echo "Top 10 des adresses IP rejetées:"
        journalctl -t kernel | grep "nft-drop" | \
        grep -oE "SRC=[0-9.]{7,15}" | sort | uniq -c | sort -nr | head -10

        echo -e "\nTop 10 des ports ciblés:"
        journalctl -t kernel | grep "nft-drop" | \
        grep -oE "DPT=[0-9]{1,5}" | sort | uniq -c | sort -nr | head -10

        echo -e "\nRépartition par protocole:"
        journalctl -t kernel | grep "nft-drop" | \
        grep -oE "PROTO=[A-Za-z]+" | sort | uniq -c | sort -nr
        ;;
    --help)
        show_help
        ;;
    *)
        echo "Option non reconnue"
        show_help
        exit 1
        ;;
esac