#!/bin/bash

# Cette configuration vous permettra de suivre facilement les paquets abandonnés 
# et d'éviter que votre fichier journal ne devienne trop volumineux. 
# Vous pourrez consulter les logs en temps réel à l'aide de la commande suivante :
# sudo tail -f /var/log/nftables.log

# Fonction pour installer ClamAV et configurer
install_clamav() {
    echo "Installation de ClamAV, clamav-daemon, et clamtk..."
    
    # Installer ClamAV, clamav-daemon et clamtk
    yay -S --noconfirm clamav clamtk

    # Créer les répertoires pour la quarantaine et les logs
    sudo mkdir -p /root/.clamav/quarantine /root/.clamav/logs
    sudo chown root:root /root/.clamav/quarantine /root/.clamav/logs
    sudo chmod 755 /root/.clamav/quarantine /root/.clamav/logs

    # Créer une tâche cron pour l'analyse ClamAV (tous les 20 du mois à 21h)
    echo "20 21 * * * /usr/bin/clamdscan --fdpass --log=/root/.clamav/logs/scan-\$(date +'%d-%m-%Y-%T').log --move=/root/.clamav/quarantine /" | sudo tee -a /etc/crontab 

    # Ajouter les chemins à exclure dans le fichier de configuration de ClamAV
    echo "# Exclure de l'analyse
    ExcludePath ^/proc
    ExcludePath ^/sys
    ExcludePath ^/run
    ExcludePath ^/dev
    ExcludePath ^/var/lib/lxcfs/cgroup
    ExcludePath ^/root/clamav/quarantine" | sudo tee -a /etc/clamav/clamd.conf 

    # Redémarrer le service clamav-daemon après modification
    sudo systemctl enable clamav.service
    sudo systemctl enable clamtk.service
}



# Script principal
install_clamav

echo "Installation et configuration terminées !"

