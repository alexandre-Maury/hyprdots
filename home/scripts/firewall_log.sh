#!/bin/bash

NFTABLES_LOG="/var/log/nftables.log"

# Vérifier si le fichier existe, sinon le créer avec les bonnes permissions
if [[ ! -f "$NFTABLES_LOG" ]]; then
    sudo groupadd nftables
    sudo usermod -aG nftables $USER
    sudo touch "$NFTABLES_LOG"
    sudo chown root:nftables "$NFTABLES_LOG"
    sudo chmod 640 "$NFTABLES_LOG"

    newgrp nftables

fi

show_help() {
    echo "Usage: $0 [option] [-o|--output]"
    echo "Options:"
    echo "  -l, --live       Afficher les logs en temps réel"
    echo "  -t, --today      Afficher les logs d'aujourd'hui"
    echo "  -h, --hour       Afficher les logs de la dernière heure"
    echo "  -s, --stats      Afficher les statistiques des rejets"
    echo "  -o, --output     Exporter les logs dans $NFTABLES_LOG"
    echo "  --help           Afficher cette aide"
}

EXPORT_TO_FILE=false

# Vérifier si l'option d'export est présente
for arg in "$@"; do
    if [[ "$arg" == "-o" || "$arg" == "--output" ]]; then
        EXPORT_TO_FILE=true
    fi
done

# Fonction pour gérer l'affichage et l'export des logs
log_output() {
    if $EXPORT_TO_FILE; then
        tee -a "$NFTABLES_LOG"
    else
        cat
    fi
}

case "$1" in
    -l|--live)
        echo "Affichage des logs en temps réel (Ctrl+C pour quitter):"
        journalctl -f -t kernel | grep --color=auto "nft-drop" | log_output
        ;;
    -t|--today)
        echo "Logs d'aujourd'hui:"
        journalctl -t kernel --since today | grep "nft-drop" | \
        awk '{print $1,$2,$3,$4,$5}' | sort | uniq -c | sort -nr | log_output
        ;;
    -h|--hour)
        echo "Logs de la dernière heure:"
        journalctl -t kernel --since "1 hour ago" | grep "nft-drop" | \
        awk '{print $1,$2,$3,$4,$5}' | sort | uniq -c | sort -nr | log_output
        ;;
    -s|--stats)
        {
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
        } | log_output
        ;;
    --help)
        show_help
        ;;
    *)
        clear && echo
        echo "Option non reconnue"
        show_help
        exit 1
        ;;
esac
