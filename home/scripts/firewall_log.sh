#!/bin/bash

NFTABLES_LOG="/var/log/nftables.log"
IP_FILTER=""  # Par défaut, aucun filtre de protocole

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
    echo "Usage: $0 [Option] [facultatif : Filtres] [facultatif : Output]"
    echo
    echo "Options :"
    echo
    echo "-l, --live                          Afficher les logs en temps réel"
    echo "-t, --today                         Afficher les logs d'aujourd'hui"
    echo "-h, --hour                          Afficher les logs de la dernière heure"
    echo "-s, --stats                         Afficher les statistiques des rejets"
    echo "-d, --date DATE PLAGE               Afficher les logs pour une date et une plage horaire (ex: -d 08/02/2025 13h-17h)"
    echo
    echo "Filtres :"
    echo "-4, --ipv4                          Filtrer les logs IPv4"
    echo "-6, --ipv6                          Filtrer les logs IPv6"
    echo
    echo "Output :"
    echo
    echo "-o, --output                        Exporter les logs dans $NFTABLES_LOG"
    echo "-c, --delete                        Vider le fichier de logs $NFTABLES_LOG"
    echo
    echo "--help                              Afficher l'aide"
}

EXPORT_TO_FILE=false

# Vérifier si l'option d'export est présente
for arg in "$@"; do
    case "$arg" in
        -o|--output)
            EXPORT_TO_FILE=true
            ;;
        -4|--ipv4)
            IP_FILTER="ipv4"
            ;;
        -6|--ipv6)
            IP_FILTER="ipv6"
            ;;
        -c|--delete)
            sudo truncate -s 0 "$NFTABLES_LOG"
            ;;
    esac
done

# Fonction pour gérer l'affichage et l'export des logs
log_output() {
    local line="$1"
    if $EXPORT_TO_FILE; then
        echo "$line" | sudo tee -a "$NFTABLES_LOG" > /dev/null
    else
        echo "$line"
    fi
}

# Fonction pour traiter les logs en temps réel
process_live_logs() {
    local filter=""
    if [[ "$IP_FILTER" == "ipv4" ]]; then
        filter="SRC=[0-9.]{7,15}"
    elif [[ "$IP_FILTER" == "ipv6" ]]; then
        filter="SRC=[0-9a-fA-F:]+"
    fi

    echo "Affichage des logs en temps réel (Ctrl+C pour quitter):"
    while read -r line; do
        if echo "$line" | grep --color=always "nft-drop" | grep -E "$filter"; then
            log_output "$line"
        fi
    done < <(journalctl -f -t kernel)
}

# Fonction pour traiter les logs d'une période spécifique
process_logs_since() {
    local since="$1"
    local count=0
    local filter=""
    if [[ "$IP_FILTER" == "ipv4" ]]; then
        filter="SRC=[0-9.]{7,15}"
    elif [[ "$IP_FILTER" == "ipv6" ]]; then
        filter="SRC=[0-9a-fA-F:]+"
    fi

    echo "Logs depuis $since:"
    echo "-------------------"

    while read -r line; do
        if echo "$line" | grep --color=always "nft-drop" | grep -E "$filter"; then
            count=$((count + 1))
            log_output "$line"  # Utilisation de log_output pour l'affichage et l'export
        fi
    done < <(journalctl -t kernel --since "$since")

    echo "-------------------"
    echo "Total des logs trouvés : $count"
}

# Fonction pour traiter les logs d'une date et d'une plage horaire spécifiques
process_logs_for_date_and_range() {
    local date="$1"
    local range="$2"
    local start_time end_time
    local filter=""
    if [[ "$IP_FILTER" == "ipv4" ]]; then
        filter="SRC=[0-9.]{7,15}"
    elif [[ "$IP_FILTER" == "ipv6" ]]; then
        filter="SRC=[0-9a-fA-F:]+"
    fi

    # Convertir la date de JJ/MM/AAAA en AAAA-MM-JJ
    local formatted_date=$(echo "$date" | awk -F '/' '{print $3 "-" $2 "-" $1}')

    # Extraire l'heure de début et de fin en s'assurant qu'elles sont bien au format HH:MM
    start_time=$(echo "$range" | cut -d '-' -f 1 | sed -E 's/h([0-9]*)?$/:\1/')
    end_time=$(echo "$range" | cut -d '-' -f 2 | sed -E 's/h([0-9]*)?$/:\1/')

    # Corriger les cas où il n'y a pas de minutes (ex: "18h" → "18:")
    if [[ "$start_time" =~ ^[0-9]{1,2}:$ ]]; then
        start_time="${start_time}00"
    fi
    if [[ "$end_time" =~ ^[0-9]{1,2}:$ ]]; then
        end_time="${end_time}00"
    fi

    # Construire les arguments pour journalctl
    local since="${formatted_date} ${start_time}:00"
    local until="${formatted_date} ${end_time}:00"

    echo "Logs du $date entre $start_time et $end_time:"
    while read -r line; do
        if echo "$line" | grep --color=always "nft-drop" | grep -E "$filter"; then
            log_output "$line"
        fi
    done < <(journalctl -t kernel --since "$since" --until "$until")
}

# Fonction pour afficher les statistiques
show_stats() {
    local filter=""
    if [[ "$IP_FILTER" == "ipv4" ]]; then
        filter="SRC=[0-9.]{7,15}"
    elif [[ "$IP_FILTER" == "ipv6" ]]; then
        filter="SRC=[0-9a-fA-F:]+"
    fi

    {
        echo "Statistiques des rejets:"
        echo "------------------------"
        echo "Top 10 des adresses IP rejetées:"
        journalctl -t kernel | grep "nft-drop" | grep -E "$filter" | \
        grep -oE "SRC=[0-9.]{7,15}" | sort | uniq -c | sort -nr | head -10

        echo -e "\nTop 10 des ports ciblés:"
        journalctl -t kernel | grep "nft-drop" | grep -E "$filter" | \
        grep -oE "DPT=[0-9]{1,5}" | sort | uniq -c | sort -nr | head -10

        echo -e "\nRépartition par protocole:"
        journalctl -t kernel | grep "nft-drop" | grep -E "$filter" | \
        grep -oE "PROTO=[A-Za-z]+" | sort | uniq -c | sort -nr
    } | while read -r line; do
        log_output "$line"
    done
}

# Gestion des options
case "$1" in
    -l|--live)
        process_live_logs
        ;;
    -t|--today)
        process_logs_since "today"
        ;;
    -h|--hour)
        process_logs_since "1 hour ago"
        ;;
    -s|--stats)
        show_stats
        ;;
    -d|--date)
        if [[ -z "$2" || -z "$3" ]]; then
            echo "Erreur: Vous devez spécifier une date et une plage horaire."
            echo "Exemple: $0 -d 08/02/2025 13h-17h"
            exit 1
        fi
        process_logs_for_date_and_range "$2" "$3"
        ;;

    --help)
        show_help
        ;;

    *)
        echo
        echo "Option non reconnue"
        echo
        show_help
        exit 1
        ;;
esac