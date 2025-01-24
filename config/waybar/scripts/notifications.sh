#!/bin/bash

# Vérifier l'argument passé
if [ "$1" == "toggle" ]; then
    # Bascule l'état de Dunst (pause/reprise)
    dunstctl set-paused toggle
    # exit 0

    # Vérifier si Dunst est en pause
    if dunstctl is-paused | grep -q "false" ; then 
        # Si Dunst est actif
        dunstify -u low -a NOTIFICATION "Les notifications sont actifs"
    fi
fi

# Récupérer le nombre de notifications en attente
COUNT=$(dunstctl count waiting)

# Définir les symboles pour les états
ENABLED=
DISABLED=

# Si des notifications sont en attente, ajouter le nombre au statut "désactivé"
if [ $COUNT != 0 ]; then 
    DISABLED=" $COUNT"
else
    DISABLED=""  # Si aucune notification, juste le symbole ""
fi

# Vérifier si Dunst est en pause
if dunstctl is-paused | grep -q "false" ; then 
    # Si Dunst est actif, afficher le symbole ""
    echo $ENABLED
else 
    # Si Dunst est en pause, afficher "" avec le nombre de notifications
    echo "$DISABLED"
fi
