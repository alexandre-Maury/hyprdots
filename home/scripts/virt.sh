#!/bin/bash

echo 
echo "=== PARAMÉTRAGE DE VBOX === " 
echo

# Ajouter l'utilisateur au groupe vboxusers
echo "Ajout de l'utilisateur au groupe vboxusers..." 
sudo usermod -aG vboxusers $USER

# Charger les modules nécessaires si non déjà chargés
echo "Chargement des modules VirtualBox..."
for module in vboxsf vboxvideo vboxdrv vboxnetadp vboxnetflt; do
    if ! lsmod | grep -q "$module"; then
        sudo modprobe "$module"
        echo "Module $module chargé."
    else
        echo "Le module $module est déjà chargé."
    fi
done

# Fonction pour gérer la création de réseaux (NAT ou Host-Only)
create_network() {
    local net_type=$1
    local default_name=$2
    local default_range=$3
    
    read -p "Souhaitez-vous spécifier un réseau $net_type personnalisé ? (y/n) : " choice

    local net_name=$default_name
    local net_range=$default_range

    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        read -p "Entrez le nom du réseau $net_type (par défaut : $default_name) : " user_name
        net_name=${user_name:-$net_name}

        read -p "Entrez la plage IP du réseau $net_type (ex : $default_range) : " user_range
        net_range=${user_range:-$net_range}
    fi

    # Vérifier si le réseau existe déjà
    if [[ "$net_type" == "natnetwork" ]]; then

        nat_network_exists=$(VBoxManage natnetwork list | grep -o "$net_name")

        if [[ -n "$nat_network_exists" ]]; then
            echo "Le réseau $net_type $net_name existe déjà. Aucune modification nécessaire."
        else

            VBoxManage natnetwork add --netname "$net_name" --network "$net_range" --enable --dhcp on

            if [[ $? -eq 0 ]]; then
                echo "Réseau NAT ajouté : $net_name avec la plage $net_range"
            else
                echo "Erreur lors de l'ajout du réseau NAT."
            fi
        fi
    fi

    # Créer et configurer le réseau Host-Only
    if [[ "$net_type" == "hostonlyif" ]]; then

        # Récupérer le nom de l'interface nouvellement créée
        hostonly_network_exists=$(VBoxManage list hostonlyifs | grep -o "$net_name")

        if [[ -n "$hostonly_network_exists" ]]; then
            echo "Le réseau $net_type $net_name existe déjà. Aucune modification nécessaire."
        else

            # commande ici

            if [[ $? -eq 0 ]]; then
                echo "Réseau NAT ajouté : $net_name avec la plage $net_range"
            else
                echo "Erreur lors de l'ajout du réseau NAT."
            fi
        fi
    fi
}

# Lister les réseaux NAT existants et demander à l'utilisateur
echo
echo "=== Réseaux NAT existants : ==="   
VBoxManage natnetwork list
default_nat="HyprNatNetwork"
default_net_range="10.0.2.0/24"
create_network "natnetwork" "$default_nat" "$default_net_range"

# Lister les interfaces host-only existantes et demander à l'utilisateur
echo
echo "=== Interfaces host-only existantes : ===" 
VBoxManage list hostonlyifs
default_host_name="HyprHostOnlyNetwork"
default_host_ip="10.0.2.0/24"
create_network "hostonlyif" "$default_host_name" "$default_host_ip"

echo 
echo "=== FIN DE PARAMÉTRAGE DE VBOX === " 
echo "Les modifications sont prises en compte. Vous devrez peut-être redémarrer votre machine ou vous déconnecter et vous reconnecter pour que les changements prennent effet."
echo
