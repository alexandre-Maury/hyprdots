#!/bin/bash

# Fonction pour afficher un menu avec wofi
afficher_menu() {
    local options="$1"
    local prompt="$2"
    echo -e "$options" | wofi --dmenu --hide_search=true --prompt="$prompt" --term=kitty --width=600 --columns 1 -I -s ~/.config/wofi/style.css
}

# Fonction pour le sous-menu "Développement"
sous_menu_developpement() {
    while true; do
        choix=$(afficher_menu "0.Retour\n1.asdf\n2.old" "Choisissez une option de développement")
        
        case $choix in
            "0.Retour")
                echo "Retour au menu précédent"
                break ;;
                
            "1.asdf")
                echo "Lancement de l'installation des plugins asdf"
                kitty ~/scripts/asdf_install.sh ;;
                
            "2.old")
                echo "Lancement de l'installation old"
                # Ajoutez ici la commande pour l'installation old
                ;;
                
            *)
                echo "Sélection invalide : $choix" ;;
        esac
    done
}

# Boucle principale
while true; do
    menu_principal="1.Tools\n2.Options\n3.Autres\n"
    config_selectionnee=$(afficher_menu "$menu_principal" "Choisissez...")
    
    if [ -z "$config_selectionnee" ]; then
        echo "Touche Échap pressée. Fin du script."
        break
    fi
    
    echo "Sélectionné : $config_selectionnee"

    case $config_selectionnee in
        "1.Tools")
            sous_menu=$(afficher_menu "0.Retour\n1.Développement\n2.Pentesting" "Choisissez une option")
            echo "Sous-menu sélectionné : $sous_menu"
            
            case $sous_menu in
                "0.Retour")
                    echo "Retour au menu principal" ;;
                    
                "1.Développement")
                    sous_menu_developpement ;;
                    
                "2.Pentesting")
                    echo "Lancement de nano pour env_var.conf"
                    kitty ~/scripts/tools.sh ;;
                    
                *)
                    echo "Sélection de sous-menu invalide : $sous_menu" ;;
            esac
            ;;
            
        "2.Options")
            sous_menu=$(afficher_menu "0.Retour\n1.Update Repo\n2.Modifier les options" "Choisissez une option")
            echo "Sous-menu sélectionné : $sous_menu"
            
            case $sous_menu in
                "0.Retour")
                    echo "Retour au menu principal" ;;
                    
                "1.Update Repo")
                    echo "Lancement de la mise à jour à venir" ;;
                    
                "2.Modifier les options")
                    echo "Mise à jour des options système à venir" ;;
                    
                *)
                    echo "Sélection de sous-menu invalide : $sous_menu" ;;
            esac
            ;;
            
        "3.Autres")
            sous_menu=$(afficher_menu "0.Retour\n1.A venir\n2.A venir" "Choisissez une option")
            echo "Sous-menu sélectionné : $sous_menu"
            
            case $sous_menu in
                "0.Retour")
                    echo "Retour au menu principal" ;;
                    
                "1.A venir")
                    echo "A venir" ;;
                    
                "2.A venir")
                    echo "A venir" ;;
                    
                *)
                    echo "Sélection de sous-menu invalide : $sous_menu" ;;
            esac
            ;;
            
        *)
            echo "Sélection invalide : $config_selectionnee" ;;
    esac
done