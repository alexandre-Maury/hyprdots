#!/bin/bash

# Fonction pour afficher les messages en couleur
print_info() {
    echo -e "\e[1;34m[INFO]\e[0m $1"
}

print_success() {
    echo -e "\e[1;32m[SUCCESS]\e[0m $1"
}

print_question() {
    echo -e "\e[1;33m[INPUT]\e[0m $1"
}

# Détecter les cartes graphiques disponibles
print_info "Détection des cartes graphiques..."
gpu_list=$(lspci | grep -E 'VGA|3D')

if [ -z "$gpu_list" ]; then
    echo "Aucune carte graphique détectée!"
    exit 1
fi

# Afficher les cartes graphiques trouvées
echo -e "\nCartes graphiques détectées:"
echo "$gpu_list"

# Obtenir les chemins DRI et les stocker dans un tableau
print_info "Analyse des chemins DRI..."
declare -a gpu_paths
declare -a gpu_info
declare -a pci_ids
declare -a gpu_models

# Collecter d'abord tous les GPU avec leurs IDs PCI
while IFS= read -r line; do
    if [[ $line =~ ^([0-9a-f]{2}:[0-9a-f]{2}\.[0-9a-f]) ]]; then
        pci_id="${BASH_REMATCH[1]}"
        model=$(echo "$line" | sed 's/.*controller: //')
        pci_ids+=("$pci_id")
        gpu_models+=("$model")
    fi
done <<< "$gpu_list"

# Maintenant associer les chemins DRI avec les informations GPU
i=0
while IFS= read -r line; do
    if [[ $line =~ pci-(.*)-card ]]; then
        pci_path="pci-${BASH_REMATCH[1]}"
        full_path="/dev/dri/by-path/$pci_path-card"
        gpu_paths+=("$full_path")
        
        # Extraire l'ID PCI du chemin
        path_pci_id=$(echo "${BASH_REMATCH[1]}" | sed 's/0000://')
        
        # Chercher le modèle correspondant
        found=false
        for j in "${!pci_ids[@]}"; do
            if [[ "${pci_ids[$j]}" == "$path_pci_id" ]]; then
                gpu_info+=("${gpu_models[$j]}")
                found=true
                break
            fi
        done
        
        if [ "$found" = false ]; then
            gpu_info+=("GPU #$((i+1)) (non identifié)")
        fi
        ((i++))
    fi
done < <(ls -l /dev/dri/by-path)

# Créer le script de démarrage
script_dir="$HOME/Scripts"
script_file="$script_dir/gpu_env.sh"

# Créer le répertoire si nécessaire
mkdir -p "$script_dir"

# Fonction pour afficher le menu de sélection
show_gpu_menu() {
    local title=$1
    echo -e "\nGPUs disponibles:"
    for i in "${!gpu_paths[@]}"; do
        if [[ ! " ${selected_indices[@]} " =~ " $i " ]]; then
            echo "$((i+1)). ${gpu_info[$i]}"
            echo "   Chemin PCI: ${gpu_paths[$i]}"
            echo "   ID PCI: ${pci_ids[$i]}"
            echo "---"
        fi
    done
}

# Sélection interactive des GPUs
declare -a selected_indices
declare -a ordered_paths
G_INTEGRATED=""
G_DISCRETE=""

print_info "Configuration des GPUs"
echo "Vous allez sélectionner vos GPUs pour Hyprland."

# Sélection du GPU intégré
show_gpu_menu "GPU intégré"
print_question "Sélectionnez le GPU intégré (1-${#gpu_paths[@]}):"
read -r selection

if [[ "$selection" =~ ^[0-9]+$ ]] && ((selection >= 1 && selection <= ${#gpu_paths[@]})); then
    G_INTEGRATED="${gpu_paths[$((selection-1))]}"
    selected_indices+=($((selection-1)))
else
    print_info "Sélection invalide, aucun GPU intégré ne sera configuré"
fi

# Demander si l'utilisateur veut configurer un GPU discret
print_question "Voulez-vous configurer un GPU discret ? (o/N):"
read -r want_discrete

if [[ "$want_discrete" =~ ^[oO] ]] && [ ${#selected_indices[@]} -lt ${#gpu_paths[@]} ]; then
    show_gpu_menu "GPU discret"
    print_question "Sélectionnez le GPU discret (1-${#gpu_paths[@]}):"
    read -r selection
    
    if [[ "$selection" =~ ^[0-9]+$ ]] && \
       ((selection >= 1 && selection <= ${#gpu_paths[@]})) && \
       [[ ! " ${selected_indices[@]} " =~ " $((selection-1)) " ]]; then
        G_DISCRETE="${gpu_paths[$((selection-1))]}"
    else
        print_info "Sélection invalide, aucun GPU discret ne sera configuré"
    fi
fi

# Écrire le script de démarrage
cat > "$script_file" << EOF
#!/bin/bash

# Configuration GPU pour Hyprland
# Les chemins PCI sont utilisés pour garantir la stabilité entre les redémarrages

EOF

# Ajouter les variables GPU seulement si elles sont définies
if [ -n "$G_INTEGRATED" ]; then
    echo "G_INTEGRATED=\"$G_INTEGRATED\"" >> "$script_file"
fi

if [ -n "$G_DISCRETE" ]; then
    echo "G_DISCRETE=\"$G_DISCRETE\"" >> "$script_file"
fi

echo "" >> "$script_file"

# Ajouter la ligne d'export en fonction des GPUs configurés
if [ -n "$G_INTEGRATED" ] && [ -n "$G_DISCRETE" ]; then
    echo 'export AQ_DRM_DEVICES="$(readlink -f $G_INTEGRATED):$(readlink -f $G_DISCRETE)"' >> "$script_file"
elif [ -n "$G_INTEGRATED" ]; then
    echo 'export AQ_DRM_DEVICES="$(readlink -f $G_INTEGRATED)"' >> "$script_file"
elif [ -n "$G_DISCRETE" ]; then
    echo 'export AQ_DRM_DEVICES="$(readlink -f $G_DISCRETE)"' >> "$script_file"
fi

# Ajouter la commande pour démarrer Hyprland
echo 'exec Hyprland "$@"' >> "$script_file"

# Rendre le script exécutable
chmod +x "$script_file"

# Création du fichier .desktop dans ~/.config/autostart/
autostart_dir="$HOME/.config/autostart"
desktop_file="$autostart_dir/gpu_env.desktop"

# Créer le répertoire autostart si nécessaire
mkdir -p "$autostart_dir"

# Créer ou modifier le fichier .desktop pour lancer le script au démarrage
cat > "$desktop_file" << EOF
[Desktop Entry]
Version=1.0
Name=GPU Environment Configuration
Comment=Lancer le script de configuration des GPU pour Hyprland
Exec=$HOME/Scripts/gpu_env.sh
Icon=utilities-terminal
Terminal=false
Type=Application
X-GNOME-Autostart-enabled=true
EOF

# Rendre le fichier .desktop exécutable
chmod +x "$desktop_file"

print_success "Fichier .desktop créé dans $desktop_file pour lancer le script au démarrage"
