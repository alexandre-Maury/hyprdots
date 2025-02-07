#!/bin/bash

echo "Installation de Exegol :"
echo
echo "Exegol est une image Docker préconfigurée pour les tests de pénétration."

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

echo "alias exegol=\"clear && cd $script_dir && source .venv/bin/activate && python3 exegol.py -v \" " | tee -a ~/.zshrc

source $HOME/.zshrc
