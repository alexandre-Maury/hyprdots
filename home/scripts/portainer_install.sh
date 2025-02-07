#!/bin/bash


echo "Installation de Portainer :"
echo
echo "Portainer est une interface de gestion pour Docker." 
echo "Il s'installe directement avec Docker et est exécuté comme un conteneur." 
echo "Exécutez cette commande pour télécharger et lancer Portainer :"

sudo docker run -d -p 9000:9000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer

echo "Accédez ensuite à l’interface de gestion de Docker avec Portainer via votre navigateur à http://localhost:9000."
echo