#!/bin/bash

# Définir les répertoires
dir2="$HOME/.config/waybar/scripts"

# Vérifier que le répertoire tmp existe, sinon le créer
mkdir -p "$HOME/.config/waybar/tmp"

# Créer un fichier de flag d'exécution si ce n'est pas déjà fait
FLAG_FILE="$HOME/.config/waybar/tmp/execution_flag"

# Fonction pour chmod sur les scripts dans un répertoire
chmod_scripts() {
    local dir="$1"
    if [ -d "$dir" ]; then
        echo "Modification des permissions pour les scripts dans $dir"
        find "$dir" -type f -iname "*.sh" -exec chmod +x {} \;
        echo "Permissions modifiées avec succès."
    else
        echo "Le répertoire $dir n'existe pas."
    fi
}

# Crée des liens symboliques et exécute baraction.sh
create_symlinks_and_run_baraction() {
    # Définir les chemins des configurations et styles desktop et laptop
    DESKTOP_CONFIG_PATH="$HOME/.config/waybar/conf/w1-config-desktop.jsonc"
    LAPTOP_CONFIG_PATH="$HOME/.config/waybar/conf/w2-config-laptop.jsonc"
    DESKTOP_STYLE_PATH="$HOME/.config/waybar/style/w1-style.css"
    LAPTOP_STYLE_PATH="$HOME/.config/waybar/style/w2-style.css"

    # Vérifier la configuration actuelle de Waybar
    CURRENT_CONFIG=$(readlink -f "$HOME/.config/waybar/config.jsonc")

    # Si le fichier de flag n'existe pas, exécuter la première configuration
    if [ ! -e "$FLAG_FILE" ]; then
        echo "Exécution initiale des scripts..."

        # Modifier les permissions des scripts
        chmod_scripts "$dir2"

        # Basculer entre les configurations Desktop et Laptop
        if [ "$CURRENT_CONFIG" = "$DESKTOP_CONFIG_PATH" ]; then
            ln -sf "$LAPTOP_CONFIG_PATH" "$HOME/.config/waybar/config.jsonc"
            ln -sf "$LAPTOP_STYLE_PATH" "$HOME/.config/waybar/style.css"
        else
            ln -sf "$DESKTOP_CONFIG_PATH" "$HOME/.config/waybar/config.jsonc"
            ln -sf "$DESKTOP_STYLE_PATH" "$HOME/.config/waybar/style.css"
        fi

        # Créer le fichier de flag pour indiquer que le script a déjà été exécuté
        echo "Création du fichier de flag : $FLAG_FILE"
        touch $FLAG_FILE        
    fi
}

# Exécuter la fonction pour créer des liens symboliques et exécuter baraction.sh
create_symlinks_and_run_baraction

# Définir le chemin pour le fichier de flag d'exécution
EXECUTION_ONCE_FLAG="$HOME/.config/waybar/tmp/execution_once_flag"

# Si le fichier de flag d'exécution n'existe pas
if [ ! -e "$EXECUTION_ONCE_FLAG" ]; then
    # Terminer les instances déjà en cours de Waybar
    pkill waybar
    # Attendre que les instances de Waybar soient complètement terminées
    sleep 5

    # Liste des configurations disponibles pour Waybar
    WAYBAR_CONFIGS=("Desktop" "Laptop")

    # Vérifier si wofi est installé
    if ! command -v wofi &>/dev/null; then
        echo "wofi n'est pas installé. Veuillez l'installer pour continuer."
        exit 1
    fi

    # Utiliser wofi pour afficher un menu interactif pour l'utilisateur
    selected_config=$(printf "%s\n" "${WAYBAR_CONFIGS[@]}" | wofi --dmenu --prompt="Choisir la configuration :" --width=600 --columns=1 -I -s --conf --style "$HOME/.config/wofi/style.css")

    # Définir les chemins des configurations et styles
    DESKTOP_CONFIG_PATH="$HOME/.config/waybar/conf/w1-config-desktop.jsonc"
    LAPTOP_CONFIG_PATH="$HOME/.config/waybar/conf/w2-config-laptop.jsonc"
    DESKTOP_STYLE_PATH="$HOME/.config/waybar/style/w1-style.css"
    LAPTOP_STYLE_PATH="$HOME/.config/waybar/style/w2-style.css"

    # Mettre à jour la configuration Waybar en fonction de la sélection de l'utilisateur
    case $selected_config in
        "Desktop")
            ln -sf "$DESKTOP_CONFIG_PATH" "$HOME/.config/waybar/config.jsonc"
            ln -sf "$DESKTOP_STYLE_PATH" "$HOME/.config/waybar/style.css"
            ;;
        "Laptop")
            ln -sf "$LAPTOP_CONFIG_PATH" "$HOME/.config/waybar/config.jsonc"
            ln -sf "$LAPTOP_STYLE_PATH" "$HOME/.config/waybar/style.css"
            ;;
        *)
            echo "Sélection invalide."
            exit 1
            ;;
    esac

    # Modifier les permissions des scripts à nouveau
    chmod_scripts "$dir2"

    # Créer le fichier de flag pour marquer l'exécution
    echo "Création du fichier de flag : $EXECUTION_ONCE_FLAG"
    touch $EXECUTION_ONCE_FLAG
fi

# Terminer les instances de Waybar déjà en cours
pkill waybar

# Attendre que les instances de Waybar soient complètement fermées
while pgrep -x waybar >/dev/null; do sleep 1; done

# Lancer Waybar
waybar &
