#!/bin/bash

help () {
  echo 'Syntax: Power <OPTION>'
  echo 'Options:'
  echo '-s, --shutdown'
  echo '-r, --reboot'
  echo '-l, --logout'
  echo '-f, --firmware'
  echo '-h, --help'
}

if [[ "$#" -le 0 ]] || [[ "$#" -gt 1 ]]; then
	printf "\033[0;31mErreur : Veuillez entrer un argument\033[0m\n"
  help
  exit 1
fi

delayedAction () {
  sleep 5
  action
}

common () {
  delayedAction &
  delayedPID=$(echo $!)
  yad --title="${1}" --button="$1":0 --button="Annuler":1 --text="\n$2 dans 5 seconds" --text-align=center --width=350

  if [[ "$?" == 0 ]]; then
    action
  else
    kill -SIGTERM $delayedPID
    echo 'Cancelled'
    exit 0
  fi
}

shutdown () {
  action () { systemctl poweroff;}
  common 'Éteindre' 'Extinction en cours'
}

reboot () {
  action () { systemctl reboot;}
  common 'Redémarrer' 'Redémarrage en cours'
}

logout () {
  action () { hyprctl dispatch exit;}
  common 'Se déconnecter' 'Déconnexion en cours'
}

firmware () {
  action () { systemctl reboot --firmware-setup;}
  common 'Redémarrer' 'Démarrage vers la configuration du firmware'
}

if [[ "$1" == '-s' ]] || [[ "$1" == '--shutdown' ]]; then
  shutdown
elif [[ "$1" == '-r' ]] || [[ "$1" == '--reboot' ]]; then
  reboot
elif [[ "$1" == '-l' ]] || [[ "$1" == '--logout' ]]; then
  logout
elif [[ "$1" == '-f' ]] || [[ "$1" == '--firmware' ]]; then
  firmware
else
  if [[ "$1" == '-h' ]] || [[ "$1" == '--help' ]]; then
    help
    exit 0
  else
    printf "\033[0;31mErreur : Argument invalide\033[0m\n"
    help
    exit 1
  fi
fi

exit 0

