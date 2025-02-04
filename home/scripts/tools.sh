#!/bin/bash


echo "Installation de Portainer :"
echo
echo "Portainer est une interface de gestion pour Docker." 
echo "Il s'installe directement avec Docker et est exécuté comme un conteneur." 
echo "Exécutez cette commande pour télécharger et lancer Portainer :"

sudo docker run -d -p 9000:9000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer

echo "Accédez ensuite à l’interface de gestion de Docker avec Portainer via votre navigateur à http://localhost:9000."
echo






echo "Installation de Exegol :"
echo
echo "Exegol est une image Docker préconfigurée pour les tests de pénétration."


# Solution 1 - Téléchargement de l'image Exegol via docker

# sudo docker pull nwodtuhs/exegol:full
# echo 'alias meta="clear && docker run --rm -it --name pentest --entrypoint bash nwodtuhs/exegol:full"' | tee -a ~/.zshrc
# source ~/.zshrc


# Solution 2 - Intallation du repo git

script_dir="$HOME/.config/exegol"

git clone https://github.com/ThePorgs/Exegol.git $script_dir

cd $script_dir

if ! command -v pip &>/dev/null; then
    echo "pip n'est pas installé. Installation de pip..."
    python3 -m ensurepip --upgrade
fi

# Création de l'environnement virtuel
echo "Création de l'environnement virtuel dans $script_dir/.venv..."
python3 -m venv "$script_dir/.venv"

# Activation de l'environnement virtuel
echo "Activation de l'environnement virtuel..."
source "$script_dir/.venv/bin/activate"

# Installation des dépendances depuis requirements.txt (si disponible)
if [ -f "requirements.txt" ]; then
    echo "Installation des paquets Python depuis requirements.txt..."
    pip install -r requirements.txt
else
    echo "Aucun fichier requirements.txt trouvé. Vous pouvez l'ajouter plus tard."
fi

# Confirmation
echo "L'environnement virtuel est prêt et les paquets ont été installés."
echo "Pour activer l'environnement virtuel à l'avenir, exécutez : l'alias [ exegol ]" 

# echo "source $script_dir/.venv/bin/activate"

echo "alias exegol=\"clear && cd $script_dir && source .venv/bin/activate && python3 exegol.py info\" " | tee -a ~/.zshrc

source $HOME/.zshrc
