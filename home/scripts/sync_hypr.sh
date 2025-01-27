#!/bin/bash

# Variables
REPO_DIR="/opt/build/hyprdots"
CONFIG_DIR="$HOME/.config"

# Fonction pour afficher les notifications
notify_user() {
    dunstify -u low -a "MAJ" "$1"
}

# Vérifier si le dépôt existe
if [ ! -d "$REPO_DIR" ]; then
    notify_user "Erreur : Le dépôt $REPO_DIR est introuvable."
    exit 1
fi

git config --global --add safe.directory $REPO_DIR

# Vérification et mise à jour du dépôt
cd "$REPO_DIR" || exit
sudo git fetch origin

# Vérifie si le dépôt local est à jour
LOCAL=$(sudo git rev-parse HEAD)
REMOTE=$(sudo git rev-parse origin/main)

if [ "$LOCAL" != "$REMOTE" ]; then
    echo "Le dépôt local n'est pas à jour. Mise à jour..."
    sudo git pull origin main --rebase
    notify_user "Le dépôt a été mis à jour avec succès."
else
    echo "Le dépôt est déjà à jour."
    notify_user "Le dépôt est déjà à jour."
fi

# Synchronisation des fichiers
echo "Synchronisation des fichiers de configuration..."
rsync -av "$REPO_DIR/config/hypr/" "$HOME/.config/hypr"
rsync -av "$REPO_DIR/config/kitty/" "$HOME/.config/kitty"
rsync -av "$REPO_DIR/config/rofi/" "$HOME/.config/rofi"
rsync -av "$REPO_DIR/config/waybar/" "$HOME/.config/waybar"
rsync -av "$REPO_DIR/config/qt5ct/" "$HOME/.config/qt5ct"
rsync -av "$REPO_DIR/config/qt6ct/" "$HOME/.config/qt6ct"
rsync -av "$REPO_DIR/config/nvim/" "$HOME/.config/nvim"
rsync -av "$REPO_DIR/config/dunst/" "$HOME/.config/dunst"
rsync -av "$REPO_DIR/config/gtk-3.0/" "$HOME/.config/gtk-3.0"

rsync -av "$REPO_DIR/home/scripts/" $HOME/scripts

chmod +x $HOME/.config/waybar/scripts/*
chmod +x $HOME/.config/hypr/scripts/*
chmod +x $HOME/scripts/*

# Notification de fin
notify_user "Vos fichiers de configuration sont à jour."






