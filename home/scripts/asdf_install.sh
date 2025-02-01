#!/bin/bash

# Repo asdf
if [ ! -f "$HOME/.local/bin/asdf" ]; then

    echo "Installation de asdf..."

    wget -O "$HOME/.config/build/tmp/asdf.tar.gz" "$ASDF_URL"
    tar -xvzf $HOME/.config/build/tmp/asdf.tar.gz -C $HOME/.local/bin

    echo "Modification du fichier $HOME/.zshrc..." | tee -a "$LOG_FILES_INSTALL"
    {
        echo "# Configuration ASDF"

        echo "export ASDF_DATA_DIR=\"\$HOME/.config/asdf\""
        echo "export PATH=\"\$ASDF_DATA_DIR/shims:\$PATH\""

        echo "mkdir -p \"\${ASDF_DATA_DIR:-\$HOME/.config/asdf}/completions\""
        echo "asdf completion zsh > \"\${ASDF_DATA_DIR:-\$HOME/.config/asdf}/completions/_asdf\""

        echo "fpath=(\${ASDF_DIR}/completions \$fpath)"
        echo "autoload -Uz compinit && compinit"
    } >> "$ZSHRC_FILE"

    echo "Les lignes ont été ajoutées avec succès dans $ZSHRC_FILE..." | tee -a "$LOG_FILES_INSTALL"

    echo "Rechargement du fichier .zshrc..." | tee -a "$LOG_FILES_INSTALL"
    source "$ZSHRC_FILE" &> /dev/null
fi

echo "Installation des plugins asdf" | tee -a "$LOG_FILES_INSTALL"

# Boucle pour installer les plugins
for git_plug in "${!ASDF_PLUGINS[@]}"; do
    url="${ASDF_PLUGINS[$git_plug]}"

    # Vérifier si le plugin existe déjà
    if [ -d "$HOME/.config/asdf/plugins/$git_plug" ]; then
        echo "Le plugin $git_plug est déjà installé, passage au suivant..." | tee -a "$LOG_FILES_INSTALL"
        continue
    fi

    echo "Installation du plugin $git_plug depuis $url ..." | tee -a "$LOG_FILES_INSTALL"
    if ! asdf plugin add "$git_plug" "$url"; then
        echo "Erreur lors de l'installation du plugin $git_plug" | tee -a "$LOG_FILES_INSTALL"
    else
        echo "Plugin $git_plug installé avec succès" | tee -a "$LOG_FILES_INSTALL"
    fi
done

# Partie usage (commentaire)
echo  | tee -a "$LOG_FILES_INSTALL"
echo "------------------------------------------"  | tee -a "$LOG_FILES_INSTALL"
echo "Utilisation basique de asdf :"  | tee -a "$LOG_FILES_INSTALL"
echo "------------------------------------------"  | tee -a "$LOG_FILES_INSTALL"
echo  | tee -a "$LOG_FILES_INSTALL"
echo "1. Installer un plugin (exemple avec Node.js)"  | tee -a "$LOG_FILES_INSTALL"
echo "asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git"  | tee -a "$LOG_FILES_INSTALL"
echo  | tee -a "$LOG_FILES_INSTALL"
echo "2. Lister toutes les versions"  | tee -a "$LOG_FILES_INSTALL"
echo "asdf list all nodejs"  | tee -a "$LOG_FILES_INSTALL"
echo  | tee -a "$LOG_FILES_INSTALL"
echo "3. Installer la dernière version stable de Node.js"  | tee -a "$LOG_FILES_INSTALL"
echo "asdf install nodejs latest"  | tee -a "$LOG_FILES_INSTALL"
echo  | tee -a "$LOG_FILES_INSTALL"
echo "4. Définir la version globale de Node.js (utilisée par défaut)"  | tee -a "$LOG_FILES_INSTALL"
echo "asdf global nodejs latest"  | tee -a "$LOG_FILES_INSTALL"
echo  | tee -a "$LOG_FILES_INSTALL"
echo "5. Vérifier la version installée de Node.js"  | tee -a "$LOG_FILES_INSTALL"
echo "node -v"  | tee -a "$LOG_FILES_INSTALL"
echo  | tee -a "$LOG_FILES_INSTALL"
echo "6. Définir une version spécifique de Node.js pour un projet"  | tee -a "$LOG_FILES_INSTALL"
echo "asdf local nodejs 14.17.0"  | tee -a "$LOG_FILES_INSTALL"
echo  | tee -a "$LOG_FILES_INSTALL"
echo "Cela crée un fichier .tool-versions dans le répertoire courant pour définir cette version localement"  | tee -a "$LOG_FILES_INSTALL"
echo ""  | tee -a "$LOG_FILES_INSTALL"
echo  | tee -a "$LOG_FILES_INSTALL"
echo "------------------------------------------"  | tee -a "$LOG_FILES_INSTALL"

