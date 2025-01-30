#!/bin/bash

# Variables
repo_dir_hyprdots="/opt/build/hyprdots"
repo_dir_hyprarch="/opt/build/hyprarch"

# Fonction pour afficher les notifications
notify_user() {
    dunstify -u low -a "MAJ" "$1"
}

# Fonction pour gérer la mise à jour d'un dépôt Git
update_repo() {
    local repo_dir="$1"
    local repo_name="$2"

    if [[ -d "$repo_dir" && -d "$repo_dir/.git" ]]; then
        echo "Mise à jour du dépôt $repo_name..."

        cd "$repo_dir" || { echo "Erreur lors de la navigation dans le dépôt $repo_name."; exit 1; }
        git reset --hard # Annuler les modifications locales
        git fetch origin || { echo "Erreur lors du fetch du dépôt $repo_name."; exit 1; }

        local local_commit=$(git rev-parse HEAD)
        local remote_commit=$(git rev-parse origin/main)

        if [ "$local_commit" != "$remote_commit" ]; then
            echo "Le dépôt $repo_name local n'est pas à jour. Mise à jour..."
            git pull origin main --rebase || { echo "Erreur lors du pull du dépôt $repo_name."; exit 1; }
            notify_user "Le dépôt $repo_name a été mis à jour avec succès."
        else
            echo "Le dépôt $repo_name est déjà à jour."
            notify_user "Le dépôt $repo_name est déjà à jour."
        fi
    else
        echo "Le répertoire $repo_dir n'existe pas ou ce n'est pas un dépôt Git valide."
        exit 1
    fi
}

# Mise à jour des dépôts
update_repo "$repo_dir_hyprdots" "hyprdots"
update_repo "$repo_dir_hyprarch" "hyprarch"

# Optionnel : Synchronisation des fichiers de configuration
echo "Synchronisation des fichiers de configuration..."

# Décommente et adapte les commandes rsync si nécessaire
# rsync -av "$repo_dir_hyprdots/config/hypr/" "$HOME/.config/hypr"
# rsync -av "$repo_dir_hyprdots/config/kitty/" "$HOME/.config/kitty"
# rsync -av "$repo_dir_hyprdots/config/rofi/" "$HOME/.config/rofi"
# rsync -av "$repo_dir_hyprdots/config/waybar/" "$HOME/.config/waybar"
# rsync -av "$repo_dir_hyprdots/config/qt5ct/" "$HOME/.config/qt5ct"
# rsync -av "$repo_dir_hyprdots/config/qt6ct/" "$HOME/.config/qt6ct"
# rsync -av "$repo_dir_hyprdots/config/nvim/" "$HOME/.config/nvim"
# rsync -av "$repo_dir_hyprdots/config/dunst/" "$HOME/.config/dunst"
# rsync -av "$repo_dir_hyprdots/config/gtk-3.0/" "$HOME/.config/gtk-3.0"

# rsync -av "$repo_dir_hyprdots/home/scripts/" "$HOME/scripts"

# chmod +x $HOME/.config/waybar/scripts/*
# chmod +x $HOME/.config/hypr/scripts/*
# chmod +x $HOME/scripts/*

# Notification de fin
notify_user "Vos fichiers de configuration sont à jour."
