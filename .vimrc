set nocompatible              " be iMproved, required
filetype off                  " required

"set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle, required
Bundle 'gmarik/vundle'
Bundle 'The-NERD-tree'
Bundle 'Syntastic'

"My plugins
Bundle 'taglist.vim'
Bundle 'https://github.com/Lokaltog/vim-powerline.git'
Bundle 'https://github.com/Valloric/YouCompleteMe.git'

filetype plugin indent on     " required

"YCM plugind
let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
nnoremap <leader>gg :YcmCompleter GoToDefinitionElseDeclaration<CR>

"Taglist plugin
let Tlist_Show_Menu = 1
let Tlist_Show_One_File = 1
let Tlist_Exit_OnlyWindow = 1
let Tlist_Use_Right_Window = 1
let Tlist_Auto_Open=1

"vim-powerline plugin
set laststatus=2
set t_Co=256
"set g:Powerline_symbols='compatible'  "only for gui mode
set encoding=utf8

"color
color desert

"cscope
nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-\>i :cs find i <C-R>=expand("<cfile>")<CR><CR>
nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>
