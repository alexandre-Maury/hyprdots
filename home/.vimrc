set nocompatible              " être amélioré, requis
filetype off                  " requis

" définit le chemin d'exécution pour inclure Vundle et l'initialiser
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" alternativement, spécifiez un chemin où Vundle doit installer les plugins
call vundle#begin('~/.vim/pack/plugins/start')

" laissez Vundle gérer Vundle, requis
Plugin 'VundleVim/Vundle.vim'

" Ce qui suit est un exemple de différents formats supportés.
" Gardez les commandes Plugin entre vundle#begin/end.

Plugin 'rose-pine/vim'

" Tous vos plugins doivent être ajoutés avant cette ligne
call vundle#end()            " requis

filetype plugin indent on    " requis

" Pour ignorer les changements d'indentation du plugin, utilisez plutôt :
"filetype plugin on
"
" Aide rapide
" :PluginList       - liste les plugins configurés
" :PluginInstall    - installe les plugins ; ajoutez `!` pour mettre à jour ou utilisez simplement :PluginUpdate
" :PluginSearch foo - recherche foo ; ajoutez `!` pour rafraîchir le cache local
" :PluginClean      - confirme la suppression des plugins inutilisés ; ajoutez `!` pour approuver la suppression automatiquement
"
" voir :h vundle pour plus de détails ou le wiki pour la FAQ
" Mettez vos éléments non-Plugin après cette ligne
