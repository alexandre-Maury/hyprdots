"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""               
"               
"               ██╗   ██╗██╗███╗   ███╗██████╗  ██████╗
"               ██║   ██║██║████╗ ████║██╔══██╗██╔════╝
"               ██║   ██║██║██╔████╔██║██████╔╝██║     
"               ╚██╗ ██╔╝██║██║╚██╔╝██║██╔══██╗██║     
"                ╚████╔╝ ██║██║ ╚═╝ ██║██║  ██║╚██████╗
"                 ╚═══╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝
"               
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""     

" === CONFIGURATION DE YouCompleteMe ===
" Instructions d'installation :
" cd ~/.vim/plugged/YouCompleteMe && python3 install.py --clangd-completer  

" === INSTALLATION AUTOMATIQUE DE VIM-PLUG ===
if empty(glob('~/.vim/autoload/plug.vim'))
  silent execute '!curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $HOME/.vimrc
endif

" === CRÉATION DU THÈME ROSE-PINE-DARK AU PREMIER LANCEMENT ===
if !isdirectory($HOME . '/.vim/colors')
  silent !mkdir -p $HOME/.vim/colors
endif

if !filereadable($HOME . '/.vim/colors/rose-pine-dark.vim')
  " Créer le fichier rose-pine-dark.vim
  call writefile([
        \ 'hi clear',
        \ 'syntax reset',
        \ 'let g:colors_name = "rose-pine-dark"',
        \ 'set background=dark',
        \ 'set t_Co=256',
        \ 'hi Normal guifg=#e0def4 ctermbg=NONE guibg=NONE gui=NONE',
        \ 'hi ErrorMsg guifg=#eb6f92 guibg=NONE',
        \ 'hi WarningMsg guifg=#eb6f92 guibg=NONE',
        \ 'hi DiffText guifg=#eb6f92 guibg=NONE',
        \ 'hi PreProc guifg=#eb6f92 guibg=NONE',
        \ 'hi Exception guifg=#eb6f92 guibg=NONE',
        \ 'hi Error guifg=#eb6f92 guibg=NONE',
        \ 'hi DiffDelete guifg=#eb6f92 guibg=NONE',
        \ 'hi GitGutterDelete guifg=#eb6f92 guibg=NONE',
        \ 'hi GitGutterChangeDelete guifg=#eb6f92 guibg=NONE',
        \ 'hi cssIdentifier guifg=#eb6f92 guibg=NONE',
        \ 'hi cssImportant guifg=#eb6f92 guibg=NONE',
        \ 'hi Function guifg=#eb6f92 guibg=NONE',
        \ 'hi Type guifg=#eb6f92 guibg=NONE',
        \ 'hi op_lv14 guifg=#eb6f92 guibg=NONE',
        \ 'hi op_lv15 guifg=#eb6f92 guibg=NONE',
        \ 'hi Identifier guifg=#9ccfd8 guibg=NONE',
        \ 'hi PMenuSel guifg=#9ccfd8 guibg=NONE',
        \ 'hi Constant guifg=#9ccfd8 guibg=NONE',
        \ 'hi Repeat guifg=#9ccfd8 guibg=NONE',
        \ 'hi DiffAdd guifg=#9ccfd8 guibg=NONE',
        \ 'hi GitGutterAdd guifg=#9ccfd8 guibg=NONE',
        \ 'hi cssIncludeKeyword guifg=#9ccfd8 guibg=NONE',
        \ 'hi Keyword guifg=#9ccfd8 guibg=NONE',
        \ 'hi op_lv16 guifg=#9ccfd8 guibg=NONE',
        \ 'hi lv16c guifg=#9ccfd8 guibg=NONE',
        \ 'hi Conceal guifg=#9ccfd8 guibg=NONE',
        \ 'hi Number guifg=#31748f guibg=NONE',
        \ 'hi IncSearch guifg=#f6c177 guibg=NONE',
        \ 'hi Title guifg=#f6c177 guibg=NONE',
        \ 'hi PreCondit guifg=#f6c177 guibg=NONE',
        \ 'hi Debug guifg=#f6c177 guibg=NONE',
        \ 'hi SpecialChar guifg=#f6c177 guibg=NONE',
        \ 'hi Conditional guifg=#f6c177 guibg=NONE gui=italic cterm=italic',
        \ 'hi Todo guifg=#f6c177 guibg=NONE',
        \ 'hi Special guifg=#f6c177 guibg=NONE',
        \ 'hi Label guifg=#f6c177 guibg=NONE',
        \ 'hi Delimiter guifg=#f6c177 guibg=NONE',
        \ 'hi CursorLineNR guifg=#f6c177 guibg=NONE',
        \ 'hi Define guifg=#f6c177 guibg=NONE',
        \ 'hi MoreMsg guifg=#f6c177 guibg=NONE',
        \ 'hi Tag guifg=#f6c177 guibg=NONE',
        \ 'hi MatchParen guifg=#f6c177 guibg=NONE',
        \ 'hi DiffChange guifg=#f6c177 guibg=NONE',
        \ 'hi GitGutterChange guifg=#f6c177 guibg=NONE',
        \ 'hi cssColor guifg=#f6c177 guibg=NONE',
        \ 'hi Folded guibg=#26233a guifg=#f6c177',
        \ 'hi FoldColumn guibg=NONE ctermbg=NONE guifg=#f6c177',
        \ 'hi Macro guifg=#c4a7e7 guibg=NONE',
        \ 'hi op_lv0 guifg=#c4a7e7 guibg=NONE',
        \ 'hi Directory guifg=#c4a7e7 guibg=NONE',
        \ 'hi markdownLinkText guifg=#c4a7e7 guibg=NONE',
        \ 'hi javaScriptBoolean guifg=#c4a7e7 guibg=NONE',
        \ 'hi Include guifg=#c4a7e7 guibg=NONE',
        \ 'hi Storage guifg=#c4a7e7 guibg=NONE',
        \ 'hi cssClassName guifg=#c4a7e7 guibg=NONE',
        \ 'hi cssClassNameDot guifg=#c4a7e7 guibg=NONE',
        \ 'hi Function guifg=#c4a7e7 guibg=NONE',
        \ 'hi String guifg=#ebbcba guibg=NONE',
        \ 'hi Statement guifg=#ebbcba guibg=NONE gui=italic cterm=italic',
        \ 'hi Operator guifg=#ebbcba guibg=NONE',
        \ 'hi cssAttr guifg=#ebbcba guibg=NONE',
        \ 'hi SignColumn guifg=#eb6f92 guibg=NONE',
        \ 'hi NonText guifg=#26233a guibg=NONE',
        \ 'hi Whitespace gui=NONE guifg=#26233a guibg=NONE',
        \ 'hi SpecialComment guifg=#26233a gui=italic guibg=#191724',
        \ 'hi StatusLineNC gui=NONE guibg=#31748f guifg=#e0def4',
        \ 'hi Search guibg=#31748f guifg=NONE',
        \ 'hi Title guifg=#e0def4',
        \ 'hi Pmenu guifg=#e0def4 guibg=#6e6a86',
        \ 'hi StatusLine gui=bold guifg=#e0def4 guibg=#908caa',
        \ 'hi Comment guifg=#908caa gui=italic',
        \ 'hi CursorLine guibg=#6e6a86',
        \ 'hi TabLineFill gui=NONE guibg=#908caa',
        \ 'hi VertSplit gui=NONE guifg=#908caa guibg=NONE',
        \ 'hi Visual gui=NONE guibg=#403d52',
        \ 'hi TabLine guifg=#5045c1 guibg=#908caa gui=NONE',
        \ 'hi LineNr guifg=#5045c1 guibg=NONE'
        \ ], $HOME . '/.vim/colors/rose-pine-dark.vim')
endif

" === CONFIGURATION DE VIM POUR LE DÉVELOPPEMENT ===

" === PARAMÈTRES DE BASE ===
syntax on                         
filetype plugin indent on          
set nonumber                       
set norelativenumber              
set tabstop=4                     
set shiftwidth=4                  
set expandtab                     
set clipboard=unnamedplus         
set nocursorline                  
set termguicolors                 
set splitbelow                    
set splitright    
set encoding=UTF-8                

" === CONFIGURATION DU GESTIONNAIRE DE PLUGINS ===
call plug#begin('~/.vim/plugged')

" === PLUGINS ===
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'vim-airline/vim-airline'
Plug 'preservim/nerdtree'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-fugitive'
Plug 'ycm-core/YouCompleteMe'     " Plugin d'autocomplétion
Plug 'scrooloose/nerdcommenter'
Plug 'jiangmiao/auto-pairs'
Plug 'dense-analysis/ale'
Plug 'ryanoasis/vim-devicons'      " Icons for Vim
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'  " Syntax highlighting in NERDTree

call plug#end()

" === INSTALLATION AUTOMATIQUE DES PLUGINS ===
augroup auto_install_plugins
  autocmd!
  autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)')) > 0 |
        \ PlugInstall --sync | source $HOME/.vimrc |
        \ endif
augroup END

" === CONFIGURATION DU THÈME ===
autocmd VimEnter * colorscheme rose-pine-dark  " Appliquer le thème Gruvbox après installation
" autocmd VimEnter * set background=dark   " Utiliser un fond sombre

" === CONFIGURATION DES PLUGINS ===

" Paramètres de NERDTree
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>
let NERDTreeShowHidden=1             " Afficher les fichiers cachés

" Activer la mise en surbrillance syntaxique dans NERDTree
let g:NERDTreeHighlightCursorline = 1
let g:NERDTreeHighlightFolders = 1
let g:NERDTreeHighlightFoldersFullName = 1
let g:NERDTreeHighlightFiles = 1
let g:NERDTreeHighlightExecFile = 1

" Paramètres de vim-airline
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#show_icons = 1

" Paramètres de FZF pour la recherche de fichiers
map <C-p> :Files<CR>

" Paramètres d'ALE (linter et correcteur)
let g:ale_fixers = {
\   'python': ['autopep8'],
\   'php': ['php_cs_fixer'],
\   'html': ['prettier'],
\   'css': ['prettier'],
\   'javascript': ['prettier'],
\   'c': ['clang-format'],
\   'cpp': ['clang-format']
\}
let g:ale_fix_on_save = 1
let g:ale_linters = {
\   'python': ['flake8'],
\   'php': ['phpcs'],
\   'c': ['gcc'],
\   'cpp': ['gcc']
\}

" Paires automatiques (fermeture automatique des parenthèses et guillemets)
let g:auto_pairs = 1

" === RACCOURCIS POUR COPIER ET COLLER ===
nnoremap <C-c> "+yy            " Copier la ligne courante dans le presse-papier
vnoremap <C-c> "+y             " Copier la sélection dans le presse-papier
nnoremap <C-v> "+p             " Coller depuis le presse-papier
vnoremap <C-v> "+p             " Coller dans une sélection visuelle

" Utilise <Tab> pour naviguer dans les suggestions
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"

" === PARAMÈTRES SPÉCIFIQUES AUX LANGAGES ===

" Paramètres spécifiques à Python
autocmd FileType python setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4

" Paramètres spécifiques à PHP
autocmd FileType php setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4

" Paramètres pour C et C++
autocmd FileType c,cpp setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4

" Paramètres pour HTML, CSS, et Markdown
autocmd FileType html,css,markdown setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2

" Aperçu Markdown (si besoin)
autocmd FileType markdown nnoremap <C-p> :!markdown-preview %<CR>
