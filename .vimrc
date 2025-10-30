set number
syntax on
set backspace=indent,eol,start
set nocompatible
set ignorecase
set smartcase
set incsearch
set autoindent
set hlsearch
set ruler
set nowrapscan
set wrap
set showcmd
set lines=33 columns=110
colorscheme desert
set guifont=Monospace\ 14
set shiftwidth=4
set tabstop=4
set expandtab
set foldmethod=marker
set foldmarker={{{,}}}

autocmd BufNewFile  *.py 0r ~/.vim/templates/python.template 
autocmd BufNewFile,BufRead *.v,*.vs,*.vh set syntax=verilog

"NERDTree
nnoremap <C-n> :NERDTreeToggle<CR>
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists('s:stdin') | NERDTree | endif
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) |
    \ execute 'NERDTree' argv()[0] | wincmd w | enew | endif
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

"EasyAlign
xmap ga <Plug>(EasyAlign)

"Other alias
:iab <expr> xtime strftime("%a, %d %b %Y %H:%M:%S %z")
nnoremap <S-t> :echo strftime('%c',getftime(expand('%')))<CR>
nnoremap <Enter> :noh<CR>
autocmd InsertEnter * set cul
autocmd InsertEnter * set cuc
autocmd InsertLeave * set nocul
autocmd InsertLeave * set nocuc

nnoremap <C-=> :exec &guifont=matchstr(&guifont, '\v[^:]+') . ':h' . (matchstr(&guifont, '\v:h(\d+)') + 1)<CR>
nnoremap <C--> :exec &guifont=matchstr(&guifont, '\v[^:]+') . ':h' . (matchstr(&guifont, '\v:h(\d+)') - 1)<CR>
