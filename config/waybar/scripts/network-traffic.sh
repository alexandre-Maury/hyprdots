#!/bin/bash

# network_traffic.sh NETWORK_INTERFACE [POLLING_INTERVAL]

# Si l'utilisateur n'a pas fourni d'interface, on prend toutes les interfaces réseau disponibles
if [ -z "$1" ]; then
    interfaces=$(ls /sys/class/net/ | grep -E '^(eth|wlan|enp|wlp)')
else
    interfaces=("$1")
fi

isecs=${2:-1}

# Fonction snore (pause sans créer de processus)
snore() {
    local IFS
    [[ -n "${_snore_fd:-}" ]] || { exec {_snore_fd}<> <(:); } 2>/dev/null
    read ${1:+-t "$1"} -u $_snore_fd || :
}

# Fonction pour rendre les valeurs humaines (B, K, M, G, etc.)
human_readable() {
  local value=$1
  local units=( B K M G T P )
  local index=0
  while (( value > 1000 && index < 5 )); do
        (( value /= 1000, index++ ))
  done
  echo "$value${units[$index]}"
}

# Vérification de la validité de l'intervalle
test "$isecs" -gt 0 || { printf '%s not valid\n' "${isecs}"; exit 1; }

# Initialisation des tableaux avec des valeurs par défaut (0)
declare -A traffic_prev

# Initialisation des statistiques pour chaque interface avec des valeurs à 0
for iface in $interfaces; do
    traffic_prev["$iface,rx_bytes"]=0
    traffic_prev["$iface,rx_packets"]=0
    traffic_prev["$iface,rx_errs"]=0
    traffic_prev["$iface,rx_drop"]=0
    traffic_prev["$iface,tx_bytes"]=0
    traffic_prev["$iface,tx_packets"]=0
    traffic_prev["$iface,tx_errs"]=0
    traffic_prev["$iface,tx_drop"]=0
done

# Boucle principale pour surveiller le trafic réseau
while snore ${isecs}; do
    # Collecte des données pour chaque interface
    for iface in $interfaces; do
        # Extraction des statistiques réseau de l'interface
        read rx_bytes rx_packets rx_errs rx_drop tx_bytes tx_packets tx_errs tx_drop < <(awk -v iface="$iface" '$1 == iface ":" {print $2, $3, $4, $5, $10, $11, $12, $13}' /proc/net/dev)
        
        if [ -z "$rx_bytes" ]; then
            echo "Erreur: Interface $iface non trouvée dans /proc/net/dev."
            continue
        fi

        # Calcul des différences de trafic
        rx_bytes_delta=$(( (rx_bytes - ${traffic_prev["$iface,rx_bytes"]}) / isecs ))
        rx_packets_delta=$(( (rx_packets - ${traffic_prev["$iface,rx_packets"]}) / isecs ))
        rx_errs_delta=$(( (rx_errs - ${traffic_prev["$iface,rx_errs"]}) / isecs ))
        rx_drop_delta=$(( (rx_drop - ${traffic_prev["$iface,rx_drop"]}) / isecs ))

        tx_bytes_delta=$(( (tx_bytes - ${traffic_prev["$iface,tx_bytes"]}) / isecs ))
        tx_packets_delta=$(( (tx_packets - ${traffic_prev["$iface,tx_packets"]}) / isecs ))
        tx_errs_delta=$(( (tx_errs - ${traffic_prev["$iface,tx_errs"]}) / isecs ))
        tx_drop_delta=$(( (tx_drop - ${traffic_prev["$iface,tx_drop"]}) / isecs ))

        # Affichage des résultats pour l'interface, sans le nom de l'interface
        printf "traffic : %5s ⇣ %5s ⇡\n" \
            $(human_readable $rx_bytes_delta) \
            $(human_readable $tx_bytes_delta)

        # Mise à jour des statistiques précédentes
        traffic_prev["$iface,rx_bytes"]=$rx_bytes
        traffic_prev["$iface,rx_packets"]=$rx_packets
        traffic_prev["$iface,rx_errs"]=$rx_errs
        traffic_prev["$iface,rx_drop"]=$rx_drop
        traffic_prev["$iface,tx_bytes"]=$tx_bytes
        traffic_prev["$iface,tx_packets"]=$tx_packets
        traffic_prev["$iface,tx_errs"]=$tx_errs
        traffic_prev["$iface,tx_drop"]=$tx_drop
    done
done
