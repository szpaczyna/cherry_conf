set termencoding=UTF-8
set encoding=UTF-8
set fileencoding=UTF-8
"set textwidth=80
set noautoindent
set showmode
set backup
set backupdir=~/.vim/backup	        " Don't create backupfiles everywhere, but just in ~/.backup
set dir=~/.vim/backup		        " Don't create backupfiles everywhere, but just in ~/.backup
set nocompatible                " niekompatybilny z VI => włącz bajery VIMa
"set backspace=indent,eol,start
set viminfo='20,\"50            " read/write a .viminfo file, don't store more than 50 lines of registers
set history=100                  " keep 50 lines of command line history
set ruler                       " show the cursor position all the time
set showcmd                     " display incomplete commands
set incsearch                   " do incremental searching
set browsedir=buffer            " To get the File / Open dialog box to default to the current file's directory
set pastetoggle=<F11>           " przełączanie w tryb wklejania (nie będzie automatycznych wcięć, ...)
set number                      " wyświetlaj nr linii
setlocal number                 " pierwszy odpalony bufor ma nrki
set wildmenu                    " wyświetlaj linie z menu podczas dopełniania
set showmatch                   " pokaz otwierający nawias gdy wpisze zamykający
set so=5                        " przewijaj juz na 5 linii przed końcem
set laststatus=2                " zawsze pokazuj linię statusu
set fo=tcrqn                    " opcje wklejania (jak maja być tworzone wcięcia itp.)
set hidden                      " nie wymagaj zapisu gdy przechodzisz do nowego bufora
set tags+=./stl_tags            " tip 931
set foldtext=MojFoldText()      " tekst po zwinięciu zakładki
set foldminlines=3              " minimum 3 linie aby powstał fold
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%04.8b]\ [HEX=\%04.4B]\ [POS=%04l,%04v][%p%%]\ [LEN=%L] 
"set statusline=%F\ %=%m%r%h%w\ %l:%v\ (%p%%)

set wildmode=longest:full      	" dopełniaj jak w BASHu
set wmnu			" show a list of all matches when tabbing a command

"set cpoptions="A"
"set keymodel=startsel,stopsel  " zaznaczanie z shiftem

let g:html_use_css = "1"
let g:calendar_monday = "1"

behave xterm

if &t_Co > 2 || has("gui_running")
        syntax on              " kolorowanie składni
        set hlsearch           " zaznaczanie szukanego tekstu
        colorscheme af               " domyślny schemat kolorów
endif
if has("gui_running")
        "set foldcolumn=2       " szerokość kolumny z zakładkami (kolumna z boku)
        "set guioptions=abegimrLtT      " m.in: włącz poziomy scrollbar
        set nowrap
        set cursorline         " zaznacz linię z kursorem
        "set cursorcolumn       " zaznacz kolumnę z kursorem
	set gfn=DejaVu\ Sans\ Mono\ 10
else
        set ts=4               " jak odpalony w konsoli to znaki tabulacji o polowe mniejsze
endif

command Code2html :source $VIMRUNTIME/syntax/2html.vim|

" Enable filetype settings
if has("eval")
	filetype on
    filetype plugin on
    filetype indent on
endif

" Removes those bloody ^M's

fun RmCR()
	t oldLine=line('.')
	e ":%s/\r//g"
	xe ':' . oldLine
endfun

map <F5> :r !date<CR>
map <F6> :call RmCR()<CR>
map <F7> :tabnew
map <F8> :tabnext
