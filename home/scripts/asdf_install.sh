#!/bin/bash

ASDF_URL="https://github.com/asdf-vm/asdf/releases/download/v0.16.0/asdf-v0.16.0-linux-amd64.tar.gz"

declare -A ASDF_PLUGINS=(
    ["nodejs"]="https://github.com/asdf-vm/asdf-nodejs.git"
    ["python"]="https://github.com/danhper/asdf-python"
    ["ruby"]="https://github.com/asdf-vm/asdf-ruby.git"
    ["java"]="https://github.com/halcyon/asdf-java.git"
    ["golang"]="https://github.com/kennyp/asdf-golang.git"
    ["elixir"]="https://github.com/asdf-vm/asdf-elixir.git"
    ["php"]="https://github.com/asdf-community/asdf-php.git"
    ["rust"]="https://github.com/code-lever/asdf-rust.git"
    ["dotnet"]="https://github.com/hensou/asdf-dotnet.git"
)

# Repo asdf
if [ ! -f "$HOME/.local/bin/asdf" ]; then

    echo "Installation de asdf..."

    wget -O "$HOME/.config/build/tmp/asdf.tar.gz" "$ASDF_URL"
    tar -xvzf $HOME/.config/build/tmp/asdf.tar.gz -C $HOME/.local/bin

    echo "Modification du fichier $HOME/.zshrc..." 
    {
        echo "# Configuration ASDF"

        echo "export ASDF_DATA_DIR=\"\$HOME/.config/asdf\""
        echo "export PATH=\"\$ASDF_DATA_DIR/shims:\$PATH\""

        echo "mkdir -p \"\${ASDF_DATA_DIR:-\$HOME/.config/asdf}/completions\""
        echo "asdf completion zsh > \"\${ASDF_DATA_DIR:-\$HOME/.config/asdf}/completions/_asdf\""

        echo "fpath=(\${ASDF_DIR}/completions \$fpath)"
        echo "autoload -Uz compinit && compinit"
    } >> "$ZSHRC_FILE"

    echo "Les lignes ont été ajoutées avec succès dans $ZSHRC_FILE..." 

    echo "Rechargement du fichier .zshrc..." 
    source "$ZSHRC_FILE" &> /dev/null
fi

echo "Installation des plugins asdf" 

# Boucle pour installer les plugins
for git_plug in "${!ASDF_PLUGINS[@]}"; do
    url="${ASDF_PLUGINS[$git_plug]}"

    # Vérifier si le plugin existe déjà
    if [ -d "$HOME/.config/asdf/plugins/$git_plug" ]; then
        echo "Le plugin $git_plug est déjà installé, passage au suivant..."
        continue
    fi

    echo "Installation du plugin $git_plug depuis $url ..."
    if ! asdf plugin add "$git_plug" "$url"; then
        echo "Erreur lors de l'installation du plugin $git_plug" 
    else
        echo "Plugin $git_plug installé avec succès" 
    fi
done

# Partie usage (commentaire)
echo  
echo "------------------------------------------"  
echo "Utilisation basique de asdf :"  
echo "------------------------------------------"  
echo  
echo "1. Installer un plugin (exemple avec Node.js)"  
echo "asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git"  
echo  
echo "2. Lister toutes les versions"  
echo "asdf list all nodejs" 
echo 
echo "3. Installer la dernière version stable de Node.js"
echo "asdf install nodejs latest"  
echo 
echo "4. Définir la version globale de Node.js (utilisée par défaut)" 
echo "asdf global nodejs latest"  
echo  
echo "5. Vérifier la version installée de Node.js"  
echo "node -v"  
echo  
echo "6. Définir une version spécifique de Node.js pour un projet"  
echo "asdf local nodejs 14.17.0"  
echo  
echo "Cela crée un fichier .tool-versions dans le répertoire courant pour définir cette version localement"  
echo 
echo "------------------------------------------"  | tee -a "$LOG_FILES_INSTALL"

