#!/bin/bash

# Résumé des commandes

    # ./luminosité.sh set <valeur> : Définit la luminosité à une valeur entre 0 et 100.
    # ./luminosité.sh increase : Augmente la luminosité de 10%.
    # ./luminosité.sh decrease : Diminue la luminosité de 10%.
    # ./luminosité.sh reset : Réinitialise la luminosité à 100%. ddcutil setvcp 10 100

# Fonction pour ajuster la luminosité
adjust_brightness() {
    local brightness=$1
    # Vérifier que la luminosité est un nombre entre 0 et 100
    if [[ "$brightness" -ge 0 ]] && [[ "$brightness" -le 100 ]]; then
        # Utilisation de ddcutil pour changer la luminosité
        ddcutil setvcp 10 "$brightness"
        echo "Luminosité réglée à $brightness%"
    else
        echo "Erreur : La luminosité doit être un nombre entre 0 et 100."
    fi
}

# Fonction pour augmenter la luminosité
increase_brightness() {
    local current_brightness
    current_brightness=$(ddcutil getvcp 10 | grep -oP '(?<=Current Value:\s)\d+')
    if [ -z "$current_brightness" ]; then
        echo "Impossible de lire la luminosité actuelle."
        exit 1
    fi
    local new_brightness=$((current_brightness + 10))
    if [ "$new_brightness" -gt 100 ]; then
        new_brightness=100
    fi
    adjust_brightness "$new_brightness"
}

# Fonction pour diminuer la luminosité
decrease_brightness() {
    local current_brightness
    current_brightness=$(ddcutil getvcp 10 | grep -oP '(?<=Current Value:\s)\d+')
    if [ -z "$current_brightness" ]; then
        echo "Impossible de lire la luminosité actuelle."
        exit 1
    fi
    local new_brightness=$((current_brightness - 10))
    if [ "$new_brightness" -lt 0 ]; then
        new_brightness=0
    fi
    adjust_brightness "$new_brightness"
}

# Vérifier les arguments passés au script
if [ $# -eq 0 ]; then
    echo "Usage : $0 [set <valeur> | increase | decrease | reset]"
    exit 1
fi

case "$1" in
    set)
        if [ -z "$2" ]; then
            echo "Erreur : Vous devez spécifier une valeur de luminosité (0-100)."
            exit 1
        fi
        adjust_brightness "$2"
        ;;
    increase)
        increase_brightness
        ;;
    decrease)
        decrease_brightness
        ;;
    reset)
        adjust_brightness 100
        ;;
    *)
        echo "Usage : $0 [set <valeur> | increase | decrease | reset]"
        exit 1
        ;;
esac
