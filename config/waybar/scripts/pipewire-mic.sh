#!/bin/bash
set -e

# Vérifier si wpctl est installé
if ! command -v wpctl &>/dev/null; then
    echo "wpctl est nécessaire pour ce script, mais il n'est pas installé."
    exit 1
fi

# Icônes pour le microphone
ICON_MICROPHONE=(
    ""  # Microphone Mute
    ""  # Microphone Actif
)

# Fichiers pour contrôler le mute du microphone
MUTE_MIC_FILE="/tmp/waybar_toggle_mute_microphone"
VOLUME_UP_FILE="/tmp/waybar_microphone_up"
VOLUME_DOWN_FILE="/tmp/waybar_microphone_down"

# Délai en secondes entre les mises à jour
DELAY=1

# Fonction pour couper le son du micro (mute/unmute)
toggle_mute_microphone() {
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
}

# Fonction pour augmenter le volume du micro
increase_microphone_volume() {
    wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%+
}

# Fonction pour diminuer le volume du micro
decrease_microphone_volume() {
    wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-
}

# Fonction pour obtenir et afficher le volume du microphone
get_microphone_volume() {
    # Récupérer le volume actuel du périphérique audio (microphone uniquement)
    INPUT=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)

    while read -r LINE; do
        # Extraire les informations de volume du microphone
        if [[ "$LINE" =~ ^Volume:.([0-9]+)\.([0-9]{2})(([[:blank:]]\[MUTED\])?)$ ]]; then
            volume=$((10#${BASH_REMATCH[1]}${BASH_REMATCH[2]}))
            # Vérifier si le micro est coupé (muté)
            if [[ -n "${BASH_REMATCH[3]}" ]]; then
                echo "${ICON_MICROPHONE[0]} $volume%"  # Icône de mute
            else
                echo "${ICON_MICROPHONE[1]} $volume%"  # Icône et volume
            fi
        fi
    done <<< "$INPUT"
}

# Vérification des fichiers d'action pour la roulette de la souris
if [[ -f "$VOLUME_UP_FILE" ]]; then
    increase_microphone_volume
    rm -f "$VOLUME_UP_FILE"  # Supprimer après l'augmentation du volume
fi

if [[ -f "$VOLUME_DOWN_FILE" ]]; then
    decrease_microphone_volume
    rm -f "$VOLUME_DOWN_FILE"  # Supprimer après la diminution du volume
fi

# Si le fichier de contrôle existe pour basculer le mute du microphone
if [[ -f "$MUTE_MIC_FILE" ]]; then
    toggle_mute_microphone
    rm -f "$MUTE_MIC_FILE"  # Supprimer le fichier après basculement
fi

# Afficher l'icône de volume du microphone et attendre les prochaines actions
get_microphone_volume
