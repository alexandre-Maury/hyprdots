#!/bin/bash

# Définition des variables
NFTABLES_CONF="/etc/nftables.conf"
NFTABLES_LOG="/var/log/nftables.log"
SERVICE_FILE="/etc/systemd/system/nftables-journald.service"

# Fonction pour gérer les erreurs
handle_error() {
    echo "Erreur : $1" >&2
    exit 1
}

# Fonction pour vérifier l'état de nftables
check_nft_status() {
    if sudo nft list ruleset | grep -q "table inet firewall"; then
        echo "active"
    else
        echo "inactif"
    fi
}

# Fonction pour activer nftables
enable_nftables() {


    # Appliquer les règles nftables
    echo "Activation du firewall..."
    if ! sudo nft -f "$NFTABLES_CONF"; then
        handle_error "Échec de l'application des règles nftables."
    fi

    # Démarrer les services systemd
    sudo systemctl start nftables.service
    echo "Firewall activé avec succès."
}

# Fonction pour désactiver nftables
disable_nftables() {

    # Flush les règles nftables
    echo "Désactivation du firewall..."
    echo "flush ruleset" | sudo nft -f -

    # Arrêter les services systemd
    sudo systemctl stop nftables.service

    # Vider le fichier de log
    sudo truncate -s 0 "$NFTABLES_LOG"

    echo "Firewall désactivé avec succès."
}

# Vérifier l'état actuel de nftables
NF_STATUS=$(check_nft_status)

# Traiter l'option passée au script
case "$1" in
    "--toggle")
        if [ "$NF_STATUS" == "active" ]; then
            disable_nftables
        else
            enable_nftables
        fi
        # Mettre à jour l'état après le basculement
        NF_STATUS=$(check_nft_status)
        ;;
esac

# Afficher l'icône et l'état avec la couleur correspondante
if [ "$NF_STATUS" == "active" ]; then
    printf "<span color=\"#32CD32\"> Firewall: Actif</span>\n"  # Vert pour actif
else
    printf "<span color=\"#FF6347\"> Firewall: Inactif</span>\n"  # Rouge pour inactif
fi