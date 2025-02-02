#!/bin/bash

echo 
echo "=== PARAMÉTRAGE DE VIRT === " 
echo


# Vérification de l'existence de la commande virsh
command -v virsh >/dev/null 2>&1 || { echo >&2 "Libvirt n'est pas installé. Veuillez installer libvirt."; exit 1; }

# Demander à l'utilisateur de choisir le type de réseau
echo "Choisissez le type de réseau pour les machines virtuelles :"
echo "1) Bridge"
echo "2) NAT"
echo "3) Host-Only"
echo "4) Isolé"
read -p "Entrez votre choix (1-4) : " NETWORK_TYPE

# Variables de base
NETWORK_PREFIX="192.168.122"  # Préfixe d'adresse IP pour le réseau
NETWORK_NAME="mynetwork"
BRIDGE_NAME="virbr0"

# Automatisation de l'IP de l'hôte (passerelle)
IP_ADDRESS="${NETWORK_PREFIX}.1"  # L'adresse de l'hôte (passerelle)

# Automatisation de la plage DHCP
DHCP_START="${NETWORK_PREFIX}.2"
DHCP_END="${NETWORK_PREFIX}.254"

# Calcul automatique du masque de sous-réseau en fonction de la plage DHCP
start_ip=$(echo "$DHCP_START" | awk -F'.' '{print $4}')
end_ip=$(echo "$DHCP_END" | awk -F'.' '{print $4}')

if [ "$end_ip" -le 254 ]; then
    NETMASK="255.255.255.0"  # Masque pour 254 adresses
else
    NETMASK="255.255.0.0"  # Masque pour un réseau plus grand
fi

# Affichage des configurations calculées
echo "Configuration du réseau ${NETWORK_NAME} :"
echo "IP de l'hôte (passerelle) : $IP_ADDRESS"
echo "Plage DHCP : $DHCP_START - $DHCP_END"
echo "Masque de sous-réseau : $NETMASK"

# Configuration du réseau en fonction du type choisi
if [ "$NETWORK_TYPE" -eq 1 ]; then
    # Configuration d'un réseau Bridge
    echo "Configuration d'un réseau Bridge..."
    cat <<EOF | sudo tee /etc/libvirt/qemu/networks/bridge.xml > /dev/null
<network>
  <name>${NETWORK_NAME}</name>
  <bridge name="${BRIDGE_NAME}" />
  <ip address="${IP_ADDRESS}" netmask="${NETMASK}">
    <dhcp>
      <range start="${DHCP_START}" end="${DHCP_END}"/>
    </dhcp>
  </ip>
</network>
EOF
    NETWORK_MODE="bridge"
    echo "Réseau Bridge configuré : ${BRIDGE_NAME}"

elif [ "$NETWORK_TYPE" -eq 2 ]; then
    # Configuration d'un réseau NAT
    echo "Configuration d'un réseau NAT..."
    cat <<EOF | sudo tee /etc/libvirt/qemu/networks/nat.xml > /dev/null
<network>
  <name>${NETWORK_NAME}</name>
  <forward mode="nat"/>
  <ip address="${IP_ADDRESS}" netmask="${NETMASK}">
    <dhcp>
      <range start="${DHCP_START}" end="${DHCP_END}"/>
    </dhcp>
  </ip>
</network>
EOF
    NETWORK_MODE="nat"
    echo "Réseau NAT configuré"

elif [ "$NETWORK_TYPE" -eq 3 ]; then
    # Configuration d'un réseau Host-Only
    echo "Configuration d'un réseau Host-Only..."
    cat <<EOF | sudo tee /etc/libvirt/qemu/networks/hostonly.xml > /dev/null
<network>
  <name>${NETWORK_NAME}</name>
  <bridge name="${BRIDGE_NAME}" stp="on" delay="0"/>
  <ip address="${IP_ADDRESS}" netmask="${NETMASK}">
    <dhcp>
      <range start="${DHCP_START}" end="${DHCP_END}"/>
    </dhcp>
  </ip>
</network>
EOF
    NETWORK_MODE="hostonly"
    echo "Réseau Host-Only configuré : ${BRIDGE_NAME}"

elif [ "$NETWORK_TYPE" -eq 4 ]; then
    # Configuration d'un réseau Isolé
    echo "Configuration d'un réseau Isolé..."
    cat <<EOF | sudo tee /etc/libvirt/qemu/networks/isolated.xml > /dev/null
<network>
  <name>${NETWORK_NAME}</name>
  <bridge name="${BRIDGE_NAME}" stp="on" delay="0"/>
  <ip address="10.0.0.1" netmask="255.255.255.0">
    <dhcp>
      <range start="10.0.0.2" end="10.0.0.254"/>
    </dhcp>
  </ip>
</network>
EOF
    NETWORK_MODE="isolated"
    echo "Réseau Isolé configuré : ${BRIDGE_NAME}"

else
    echo "Choix invalide. Veuillez entrer un nombre entre 1 et 4."
    exit 1
fi

# Définir, démarrer et activer le réseau libvirt
echo "Définition et démarrage du réseau..."
sudo virsh net-define /etc/libvirt/qemu/networks/${NETWORK_MODE}.xml
sudo virsh net-start ${NETWORK_NAME}
sudo virsh net-autostart ${NETWORK_NAME}

# Vérifier le statut du réseau
echo "Vérification du statut du réseau ${NETWORK_NAME}..."
sudo virsh net-list --all

# Redémarrage des services libvirt
echo "Redémarrage des services libvirt..."
sudo systemctl restart libvirtd

echo "Réseau ${NETWORK_NAME} de type ${NETWORK_MODE} configuré et activé avec succès."
echo "Vous pouvez maintenant connecter vos machines virtuelles à ce réseau."

echo 
echo "=== FIN DE PARAMÉTRAGE DE VIRT === "
echo
