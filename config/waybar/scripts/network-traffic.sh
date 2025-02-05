#!/bin/bash

# Déterminer l'interface active
active_iface=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5}')
if [[ -z "$active_iface" ]]; then
    echo " No active interface"
    exit 1
fi

# Intervalle de temps (en secondes) pour calculer le débit
isecs=${1:-1}

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

# Initialisation des statistiques précédentes
rx_bytes_prev=0
tx_bytes_prev=0

# Boucle principale pour surveiller le trafic réseau
while snore ${isecs}; do
    # Extraction des statistiques réseau de l'interface active
    read rx_bytes tx_bytes < <(awk -v iface="$active_iface" '$1 == iface ":" {print $2, $10}' /proc/net/dev)

    if [[ -z "$rx_bytes" ]]; then
        echo " Interface $active_iface not found"
        exit 1
    fi

    # Calcul des différences de trafic
    rx_bytes_delta=$(( (rx_bytes - rx_bytes_prev) / isecs ))
    tx_bytes_delta=$(( (tx_bytes - tx_bytes_prev) / isecs ))

    # Affichage des résultats avec des icônes
    printf " %5s ⇣  %5s ⇡\n" \
        $(human_readable $rx_bytes_delta) \
        $(human_readable $tx_bytes_delta)

    # Mise à jour des statistiques précédentes
    rx_bytes_prev=$rx_bytes
    tx_bytes_prev=$tx_bytes
done