###########################################################
# Filename:      config-vim.sh
# Author:        sunxidong
# Email:         sunxidong9999@gmail.com
# Created:       2024-10-28 04:07:45
# Last modified: 2024-10-28 04:07:45
# Description:   
##########################################################
#!/bin/bash

INSPROC=
GHPROXY=
USERNAME=
USEREMAIL=
CTAGS=
NOUPDATE=
VUNDLE=${GHPROXY}https://github.com/VundleVim/Vundle.vim.git
REPO=~/.vim/bundle/Vundle.vim

if [[ -f /etc/redhat-release ]] || 
	grep -qi -E "kylin" /etc/os-release || 
	grep -qi -E "centos|red hat|redhat" /etc/issue || 
	grep -qi -E "centos|red hat|redhat" /proc/version; then
	INSPROC=yum
	CTAGS=ctags
	NOUPDATE=--setopt=obsoletes=0
elif grep -qi -E "debian|ubuntu" /etc/issue; then
	INSPROC=apt
	CTAGS=universal-ctags
	NOUPDATE=--no-upgrade
else
	echo "Unsupported System"
	exit -1
fi

check_dependency() {
	echo "Check dependency ..."

	mkdir -p ~/.vim/bundle ~/.vim/syntax

	sudo $INSPROC install -y $CTAGS cscope vim git $NOUPDATE

	echo "Check dependency done."
}

install_vimplugins() {
	if [[ ! -d "$REPO" ]]; then
		git clone ${GHPROXY}https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	else
		git --git-dir="$REPO/.git" --work-tree="$REPO" pull
	fi
	vim +PluginInstall +qall
	vim +GoInstallBinaries +qall
}

config_vimrc() {
	cat > ~/.vimrc << EOF
if has("syntax")
    syntax on
endif

set nu

set shiftwidth=4
set tabstop=4 
set autoindent
set cindent
set cursorline

set autoread

set hlsearch
"set nohlsearch
set incsearch
set ignorecase
set smartcase       " Do smart case matching

set noeb
set laststatus=2

set showmode
set showcmd

set ruler

set wildmenu
set wildmode=longest:list,full

set statusline=\\ %<%F[%1*%M%*%n%R%H]%=\\ %y\\ %0(%{&fileformat}\\ %{&encoding}\\ %c:%l/%L%)\\

set autowriteall

set enc=utf-8
set fencs=utf-8,ucs-bom,shift-jis,gb18030,gbk,gb2312,cp936
set langmenu=zh_CN.UTF-8
set helplang=cn

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin '${GHPROXY}https://github.com/VundleVim/Vundle.vim'
Plugin '${GHPROXY}https://github.com/fatih/vim-go'
Plugin '${GHPROXY}https://github.com/majutsushi/tagbar'
Plugin '${GHPROXY}https://github.com/scrooloose/nerdtree'

call vundle#end()            " required
filetype plugin indent on    " required

nmap <C-h> <C-W>h
nmap <C-j> <C-W>j
nmap <C-k> <C-W>k
nmap <C-l> <C-W>l

nmap <C-n> :nohl<CR>

nmap <F5> :edit<CR>

nmap <F6> :set paste<CR>
nmap <F7> :set nopaste<CR>

function UpdateTitle()
    normal m'
    execute '/* Last modified\s*:/s@:.*$@\=strftime(": %Y-%m-%d %H:%M:%S")@'
    normal "
    normal mk
    execute '/* Filename\s*:/s@:.*$@\=":      ".expand("%:t")@'
    execute "noh"
    normal 'k
    echohl WarningMsg | echo "Successful in updating the copy right." | echohl None
endfunction

function AddTitle()
    call append(0,"/**********************************************************")
    call append(1," * Filename:      ".expand("%:t"))
    call append(2," * Author:        $USERNAME")
    call append(3," * Email:         $USEREMAIL")
    call append(4," * Created:       ".strftime("%Y-%m-%d %H:%M:%S"))
    call append(5," * Last modified: ".strftime("%Y-%m-%d %H:%M:%S"))
    call append(6," * Description: ")
    call append(7," * *******************************************************/")
    echohl WarningMsg | echo "Successful in adding the copyright." | echohl None
endfunction

function AddAuthor()
    let n=1
    while n < 7
        let line = getline(n)
        if line =~'^\s*\*\s*\S*Last\s*modified\s*:\s*\S*.*$'
            call UpdateTitle()
            return
        endif
        let n = n + 1
    endwhile
    call AddTitle()
endfunction
map <F9> ms:call AddAuthor()<cr>'s

function UpdateTitle_M()
    normal m'
    execute '/# Last modified\s*:/s@:.*$@\=strftime(": %Y-%m-%d %H:%M:%S")@'
    normal "
    normal mk
    execute '/# Filename\s*:/s@:.*$@\=":      ".expand("%:t")@'
    execute "noh"
    normal 'k
    echohl WarningMsg | echo "Successful in updating the copy right." | echohl None
endfunction

function AddTitle_M()
    call append(0,"###########################################################")
    call append(1,"# Filename:      ".expand("%:t"))
    call append(2,"# Author:        $USERNAME")
    call append(3,"# Email:         $USEREMAIL")
    call append(4,"# Created:       ".strftime("%Y-%m-%d %H:%M:%S"))
    call append(5,"# Last modified: ".strftime("%Y-%m-%d %H:%M:%S"))
    call append(6,"# Description:   ")
    call append(7,"##########################################################")
    echohl WarningMsg | echo "Successful in adding the copyright." | echohl None
endfunction

function AddAuthor_M()
    let n=1
    while n < 7
        let line = getline(n)
        if line =~'^#\s*\S*Last\s*modified\s*:\s*\S*.*$'
            call UpdateTitle_M()
            return
        endif
        let n = n + 1
    endwhile
    call AddTitle_M()
endfunction
map <F10> ms:call AddAuthor_M()<cr>'s

"==============================================================
if has("cscope") && filereadable("/usr/bin/cscope")
   set csprg=/usr/bin/cscope
   set csto=0
   set cst
   set nocsverb
   " add any database in current directory
   if filereadable("cscope.out")
      cs add cscope.out
   " else add database pointed to by environment
   elseif \$CSCOPE_DB != ""
      cs add \$CSCOPE_DB
   endif
   set csverb
endif
nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>

nmap <F2> :TagbarToggle<CR>   "设置快捷键
let g:tagbar_width = 25       "设置宽度，默认为40
autocmd VimEnter * nested :call tagbar#autoopen(1)    "打开vim时自动打开tagbar
let g:tagbar_sort = 0       "按函数在源码中出现的顺序排序（为1则按函数名称排序）
let g:tagbar_left = 1       "在左侧
"let g:tagbar_right = 1     "在右侧
let g:tagbar_type_go = {
    \ 'ctagstype' : 'go',
    \ 'kinds'     : [
        \ 'p:package',
        \ 'i:imports:1',
        \ 'c:constants',
        \ 'v:variables',
        \ 't:types',
        \ 'n:interfaces',
        \ 'w:fields',
        \ 'e:embedded',
        \ 'm:methods',
        \ 'r:constructor',
        \ 'f:functions'
    \ ],
    \ 'sro' : '.',
    \ 'kind2scope' : {
        \ 't' : 'ctype',
        \ 'n' : 'ntype'
    \ },
    \ 'scope2kind' : {
        \ 'ctype' : 't',
        \ 'ntype' : 'n'
    \ },
    \ 'ctagsbin'  : 'gotags',
    \ 'ctagsargs' : '-sort -silent'
\ }

let NERDTreeWinPos='right'
let NERDTreeShowLineNumbers=1
let NERDTreeWinSize=25
let NERDChristmasTree=1
let NERDTreeAutoCenter=1
nnoremap <F4> :NERDTreeToggle<CR>

"================== Golang ===================
au filetype go inoremap <buffer> . .<C-x><C-o>

"This may overwrite syntax in "~/.vim/syntax/go.vim"
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_operators = 1

let g:go_fmt_autosave = 1
let g:go_fmt_command = "goimports"

"Status line types/signatures
let g:go_auto_type_info = 1

function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#test#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction

"Map keys for most used commands.
"Ex: '\b' for building, '\r' for running and '\t' for running test.
autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>
autocmd FileType go nmap <leader>r  <Plug>(go-run)
autocmd FileType go nmap <leader>t  <Plug>(go-test)
autocmd FileType go nmap <leader>f  <Plug>(go-fmt)

EOF

	cat >> ~/.vim/syntax/c.vim << EOF
"highlight Functions
syn match cFunctions "\<[a-zA-Z_][a-zA-Z_0-9]*\>[^()]*)("me=e-2
syn match cFunctions "\<[a-zA-Z_][a-zA-Z_0-9]*\>\s*("me=e-1
hi cFunctions gui=NONE cterm=bold  ctermfg=blue
EOF

	cat >> ~/.vim/syntax/go.vim << EOF
"highlight Functions
syn match cFunctions "\<[a-zA-Z_][a-zA-Z_0-9]*\>[^()]*)("me=e-2
syn match cFunctions "\<[a-zA-Z_][a-zA-Z_0-9]*\>\s*("me=e-1
hi cFunctions gui=NONE cterm=bold  ctermfg=blue
EOF
}

usage() {
	cat << EOF

Usage:
  $1 <options> <parameters>

  The script is used to config vim.

Options:
  -g <proxy>: specify github proxy (e.g. -g https://ghp.ci)
  -u <username>: specify username that shows in file title
  -e <user's email>: specify user's email address that shows in file title
  -h: Show this usage message

e.g.:
  $1 -u SunXidong -e admin@example.com

EOF
}

while getopts "u:e:g:h" opt; do
	case $opt in
		g) arg=$OPTARG
			while [[ "${arg: -1}" = "/" ]]; do
				arg="${arg::-1}"
			done
			GHPROXY=${arg}/
			;;
		u) USERNAME=$OPTARG
			;;
		e) USEREMAIL=$OPTARG
			;;
		h) usage $0
			;;
		\?) exit 1
			;;
	esac
done



check_dependency

config_vimrc

install_vimplugins

