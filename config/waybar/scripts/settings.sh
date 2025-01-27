#!/bin/bash

while true; do
    menu_principal="1. Hyprland\n2. Waybar\n3. Styles Waybar\n4. Options"
    config_selectionnee=$(echo -e "$menu_principal" | wofi --dmenu --hide_search=true --prompt=Choisissez... --term=kitty --width=600 --columns 1 -I -s ~/.config/wofi/style.css)
    
    # Vérifiez si la touche Échap a été pressée
    if [ "$config_selectionnee" == "" ]; then
        echo "Touche Échap pressée. Fin du script."
        break
    fi
    
    echo "Sélectionné : $config_selectionnee"

case $config_selectionnee in
    "1. Hyprland")
        sous_menu=$(echo -e "0. Retour au menu principal\n1. hyprland.conf\n2. env_var.conf\n3. display.conf\n4. ~/.config/hypr/conf/workspaces.conf\n5. ~/.config/hypr/conf/key_binds.conf\n6. ~/.config/hypr/conf/window_binds.conf\n7. ~/.config/hypr/conf/window_rules.conf" | wofi --dmenu --hide_search=true --prompt=Choisissez... --term=kitty --width=600 --columns 1 -I -s ~/.config/wofi/style.css)
        echo "Sous-menu sélectionné : $sous_menu"
        case $sous_menu in
            "0. Retour au menu principal")
                echo "Retour au menu principal" ;;
            "1. hyprland.conf")
                echo "Lancement de nano pour hyprland.conf"
                kitty nano ~/.config/hypr/hyprland.conf ;;
            "2. env_var.conf")
                echo "Lancement de nano pour env_var.conf"
                kitty nano ~/.config/hypr/env_var.conf ;;
            "3. display.conf")
                echo "Lancement de nano pour display.conf"
                kitty nano ~/.config/hypr/hyprland/display.conf ;;
            "4. ~/.config/hypr/conf/workspaces.conf")
                echo "Lancement de nano pour workspaces.conf"
                kitty nano ~/.config/hypr/conf/workspaces.conf ;;
            "5. ~/.config/hypr/conf/key_binds.conf")
                echo "Lancement de nano pour key_binds.conf"
                kitty nano ~/.config/hypr/conf/key_binds.conf ;;
            "6. ~/.config/hypr/conf/window_binds.conf")
                echo "Lancement de nano pour window_binds.conf"
                kitty nano ~/.config/hypr/conf/window_binds.conf ;;                
            "7. ~/.config/hypr/conf/window_rules.conf")
                echo "Lancement de nano pour window_rules.conf"
                kitty nano ~/.config/hypr/conf/window_rules.conf ;;
            *)
                echo "Sélection de sous-menu invalide : $sous_menu" ;;
        esac
            ;;
        "2. Configurations Waybar")
            sous_menu=$(echo -e "0. Retour au menu principal\n1. ~/.config/waybar/conf/w1-config-desktop.jsonc\n2. ~/.config/waybar/conf/w2-config-laptop.jsonc" | wofi --dmenu --hide_search=true --prompt=Choisissez... --term=kitty --width=600 --columns 1 -I -s ~/.config/wofi/style.css)
            echo "Sous-menu sélectionné : $sous_menu"
            case $sous_menu in
                "0. Retour au menu principal")
                    echo "Retour au menu principal" ;;
                "1. ~/.config/waybar/conf/w1-config-desktop.jsonc")
                    echo "Lancement de nano pour w1-config-desktop.jsonc"
                    kitty nano ~/.config/waybar/conf/w1-config-desktop.jsonc ;;
                "2. ~/.config/waybar/conf/w2-config-laptop.jsonc")
                    echo "Lancement de nano pour w2-config-laptop.jsonc"
                    kitty nano ~/.config/waybar/conf/w2-config-laptop.jsonc ;;
                *)
                    echo "Sélection de sous-menu invalide : $sous_menu" ;;
            esac
            ;;
        "3. Styles Waybar")
            sous_menu=$(echo -e "0. Retour au menu principal\n1. ~/.config/waybar/style/w1-style.css\n2. ~/.config/waybar/style/w2-style.css" | wofi --dmenu --hide_search=true --prompt=Choisissez... --term=kitty --width=600 --columns 1 -I -s ~/.config/wofi/style.css)
            echo "Sous-menu sélectionné : $sous_menu"
            case $sous_menu in
                "0. Retour au menu principal")
                    echo "Retour au menu principal" ;;
                "1. ~/.config/waybar/style/w1-style.css")
                    echo "Lancement de nano pour w1-style.css"
                    kitty nano ~/.config/waybar/style/w1-style.css ;;
                "2. ~/.config/waybar/style/w2-style.css")
                    echo "Lancement de nano pour w2-style.css"
                    kitty nano ~/.config/waybar/style/w2-style.css ;;
                *)
                    echo "Sélection de sous-menu invalide : $sous_menu" ;;
            esac
            ;;

        *)
            echo "Sélection invalide : $config_selectionnee" ;;
    esac
done
