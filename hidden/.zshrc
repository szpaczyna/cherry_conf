# zshrc  - ZSH Configuration file

export TERM="xterm"
export GREP_COLOR=31
export EDITOR=/usr/bin/vim
export LC_ALL=pl_PL.UTF-8
export LANG=pl_PL.UTF-8
export EIX_LIMIT=0

local RED=$'%{\e[0;31m%}'
local GREEN=$'%{\e[0;32m%}'
local YELLOW='%{\e[0;33m%}'
local BLUE=$'%{\e[0;34m%}'
local PINK=$'%{\e[0;35m%}'
local CYAN=$'%{\e[0;36m%}'
local GREY=$'%{\e[1;30m%}'
local NORMAL=$'%{\e[0m%}'
local NORMAL1="\e[0m"
local RED1="\e[0;31m"
local BLUE1="\e[0;36m"

autoload -U compinit promptinit tetris zcalc url-quote-magic colors zfinit
compinit
colors
zfinit

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*:(rm|kill|diff):*' ignore-line yes
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:(all-|)files' ignored-patterns '(|*/)CVS'
zstyle ':completion:*:cd:*' ignored-patterns '(*/)#CVS'
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:processes' command 'ps xw -o pid,tty,time,args'
zstyle ':completion:*' menu select=long-list select=1

zle '-N' tetris
zle '-N' url-quote-magic

export WORDCHARS='*?_[]~\!#$%^<>|`@#$%^*()+?'

setopt notify correct
setopt correctall autocd
setopt short_loops
setopt nohup
setopt extended_history
setopt extendedglob
setopt interactivecomments
setopt hist_ignore_all_dups
setopt auto_remove_slash
setopt short_loops
setopt rmstarsilent

typeset -A abbreviations
abbreviations=(
  "Im"    "| more"
  "Ia"    "| awk"
  "Ig"    "| grep"
  "Ieg"   "| egrep"
  "Ih"    "| head"
  "It"    "| tail"
  "Is"    "| sort"
  "Iw"    "| wc"
  "Ix"    "| xargs"
)

if [[ -f ~/.dir_colors ]]; then
        eval `dircolors -b ~/.dir_colors`
else
        eval `dircolors -b /etc/DIR_COLORS`
fi

promptinit
export PS1="$(print "${NORMAL}[${GREEN}%m${NORMAL}][${YELLOW}%~${NORMAL}]${GREEN} %(!.#.$) ${NORMAL}")"

alias ls="ls --color=auto --classify $*"
alias l="ls"
alias ll="ls -l"
alias la="ls -lA"
alias grep='grep --color=auto'
alias df='df -hT'
alias -g '....'='../../..'
alias -g M="| more"
alias -g H="| head"
alias -g T="| tail"
alias -g G="| grep"
alias -g L="| less"
alias su="su -"
alias terminator="terminator --geometry=800x440"
alias mplayer="mpv"
alias minecraft="cd /home/shpaq/.minecraft && java -jar /home/shpaq/scripts/minecraft.jar"

umask 022

alias loki='ssh shpaq@ping.vim.hu'
alias daisy='ssh root@daisy'
alias squirrel='ssh root@squirrel'
alias every='ssh root@every'

watch=all
logcheck=30
WATCHFMT="User %n has %a on tty %l at %T %W"

users=(shpaq root)
zstyle ':completion:*' users $users

if [[ -f ~/.ssh/known_hosts ]]; then
    _myhosts=(${${${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[0-9]*}%%\ *}%%,*}#\[}/]:*/})
    zstyle ':completion:*' hosts $_myhosts
fi

[[ -t 1 ]] || return
    case $TERM in
            *xterm*|*rxvt*|(dt|k|E)term)
            precmd() {
                    print -Pn "\e]2;[%n] : [%m] : [%~]\a"
                }
        preexec() {
            print -Pn "\e]2;[%n] : [%m] : [%~] : [ $1 ]\a"
            }
    ;;
    esac

export HISTSIZE=5000
export HISTFILE=~/.history_zsh
export SAVEHIST=4000
export EDITOR="/usr/bin/vim"

bindtc ()
{
            setopt localoptions
            local keyval=$(echotc "$1" 2>&-)
            [[ $keyval == "no" ]] && keyval=""
            bindkey "${keyval:-$2}" "$3"
}

bindtc kP "^[[I" history-beginning-search-backward
bindtc kN "^[[G" history-beginning-search-forward
bindtc kh "^[[H" beginning-of-line
bindtc kH "^[[F" end-of-line

case $TERM in (xterm*)
        bindkey "\e[H" beginning-of-line
        bindkey "\e[F" end-of-line
esac

bindkey "\e[3~" delete-char
bindkey '\e[1~' beginning-of-line
bindkey '\e[4~' end-of-line
bindkey "^R" history-incremental-search-backward
bindkey '^T' tetris
bindkey "^[[3" backward-delete-word
bindkey "^[OF" end-of-line
bindkey "^[OH" beginning-of-line
bindkey "^[a" accept-and-hold >/dev/null 2>&1

keychain -q ~/.ssh/id_rsa
source ~/.keychain/$(hostname)-sh

decomment () {
        egrep -v '^([[:space:]]*#|$)' $@
}

shot() {
 	[[ ! -d ~/Pictures/shots ]] && mkdir ~/Pictures/shots
	cd ~/Pictures/shots
 	[[ -z "$1" ]] && echo "Failed with no argument!" && return 
	scrot -cd 3 $(date +%Y_%m_%d_%H-%M)-$1.png
}

limg() {
    local -a images
    images=( *.{jpg,jpeg,gif,png,JPG,JPEG,GIF,PNG}(.N) )
    if [[ $#images -eq 0 ]] ; then
        print "No image files found."
    else
        ls "$@" "$images[@]"
    fi
}

status() {
echo ""
echo "${BLUE1}System${NORMAL1}      $(cat /etc/gentoo-release)"
echo "${BLUE1}Kernel${NORMAL1}      $(uname -rv)"
echo "${BLUE1}CPU${NORMAL1}         $(uname -p)"
echo "${BLUE1}Date${NORMAL1}        $(date "+%Y-%m-%d %H:%M:%S")"
echo "${BLUE1}Shell${NORMAL1}       Zsh $ZSH_VERSION (PID = $$, $SHLVL nests)"
echo "${BLUE1}Term${NORMAL1}        $TTY ($TERM), $BAUD bauds, $COLUMNS x $LINES cars"
echo "${BLUE1}Login${NORMAL1}       $LOGNAME @ $HOST" #(UID = $EUID)
echo "${BLUE1}Uptime${NORMAL1}     $(uptime)"
echo ""
}

genthumbs () {
    for f in *.(gif|jpeg|jpg|png)
                do
                    convert -size 160x320 "$f" -resize 160x320 thumb-"$f"
                    convert -resize 50% "$f" med-"$f"
            done
}

2html() {
    vim -n -c ':so $VIMRUNTIME/syntax/2html.vim' -c ':wqa' $1 > /dev/null 2> /dev/null
}

space_rm() {
    for file in *; do
        mv ${file} ${file:gs/\ /./}
    done
}

lowercase_mv() {
    for file in *; do
        mv ${file} ${file//(#m)[A-Z]/${(L)MATCH}}
    done
}
# DIE SATANA!
die() {
	echo $1
	return 0
}

# Some functions especially for portage. Changing dir to packages dir in $PORTDIR.

ecd() {
	local pc d file has

	pc=$(efind $*)
	d=$(eportdir)

	if [[ $pc == "" ]] ; then
	 echo "nothing found for $*"
	 return 1
	fi

	cd ${d}/${pc}
	if [[ -n "$1" ]]; then

	index=1
	for file in *.ebuild; do
		has="0"
		if [[ -d /var/db/pkg/${pc%/*}/${file%.ebuild} ]]; then
			   has="1"
		fi
		if [[ "${has}" == "1" ]]; then
			print "   [$fg[red]*${index}*$fg[default]]     ${file%.ebuild}"
		else
			print "   [$fg[green] ${index} $fg[default]]     ${file%.ebuild}"
		fi
		((index++))
	done
	fi
		
}

eportdir() {
if [[ -n "${PORTDIR_CACHE}" ]] ; then
	    echo "${PORTDIR_CACHE}"
	elif [[ -d "${HOME}"/gentoo/gentoo-x86 ]]; then
	    PORTDIR_CACHE="${HOME}"/gentoo/gentoo-x86 eportdir
	elif [[ -d /usr/portage ]] ; then
	    PORTDIR_CACHE="/usr/portage" eportdir
	else
	    PORTDIR_CACHE="$(portageq portdir )" eportdir
	fi
}

echo1() {
			echo "$1"
	}
efind() {
	local efinddir cat pkg
	efinddir=$(eportdir)

	case $1 in
	    *-*/*)
	    pkg=${1##*/}
	    cat=${1%/*}
	    ;;

	    ?*)
	    pkg=${1}
	    cat=$(echo1 ${efinddir}/*-*/${pkg}/*.ebuild)
	    [[ -f $cat ]] || cat=$(echo1 ${efinddir}/*-*/${pkg}*/*.ebuild)
	    [[ -f $cat ]] || cat=$(echo1 ${efinddir}/*-*/*${pkg}/*.ebuild)
	    [[ -f $cat ]] || cat=$(echo1 ${efinddir}/*-*/*${pkg}*/*.ebuild)
	    if [[ ! -f $cat ]]; then
	        return 1
	    fi
	    pkg=${cat%/*}
	    pkg=${pkg##*/}
	    cat=${cat#${efinddir}/}
	    cat=${cat%%/*}
	    ;;
	esac

	echo ${cat}/${pkg}
}

# Check metadata files for herd and devs responsible for t3h package
ewho() {
	local pc d metadata f

	pc=$(efind $*)
	d=$(eportdir)
	f=0

	if [[ $pc == "" ]] ; then
	    echo "nothing found for $*"
	    return 1
	fi

	metadata="${d}/${pc}/metadata.xml"
	if [[ -f "${metadata}" ]] ; then
	    echo "metadata.xml says:"
	    sed -ne 's,^.*<herd>\([^<]*\)</herd>.*,  herd:  \1,p' \
	    "${metadata}"
	    sed -ne 's,^.*<email>\([^<]*\)@[^<]*</email>.*,  dev:   \1,p' \
	    "${metadata}"
	    f=1
	fi

	if [[ -d ${d}/${pc}/CVS ]] ; then
	    echo "CVS log says:"
	    pushd ${d}/${pc} > /dev/null
	    for e in *.ebuild ; do
	        echo -n "${e}: "
	        cvs log ${e} | sed -e '1,/^revision 1\.1$/d' | sed -e '2,$d' \
	        -e "s-^.*author: --" -e 's-;.*--'
	    done
	    popd > /dev/null
	    f=1
	fi

	if [[ f == 0 ]] ; then
	    echo "Nothing found"
	    return 1
	fi
	return 0
}

## git bullshit
setopt prompt_subst

# Modify the colors and symbols in these variables as desired.
GIT_PROMPT_SYMBOL="%{$fg[blue]%}±"
GIT_PROMPT_PREFIX="%{$fg[green]%}[%{$reset_color%}"
GIT_PROMPT_SUFFIX="%{$fg[green]%}]%{$reset_color%}"
GIT_PROMPT_AHEAD="%{$fg[red]%}ANUM%{$reset_color%}"
GIT_PROMPT_BEHIND="%{$fg[cyan]%}BNUM%{$reset_color%}"
GIT_PROMPT_MERGING="%{$fg_bold[magenta]%}⚡︎%{$reset_color%}"
GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}●%{$reset_color%}"
GIT_PROMPT_MODIFIED="%{$fg_bold[yellow]%}●%{$reset_color%}"
GIT_PROMPT_STAGED="%{$fg_bold[green]%}●%{$reset_color%}"

# Show Git branch/tag, or name-rev if on detached head
parse_git_branch() {
  (git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
}

# Show different symbols as appropriate for various Git repository states
parse_git_state() {

  # Compose this value via multiple conditional appends.
  local GIT_STATE=""

  local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_AHEAD" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_AHEAD//NUM/$NUM_AHEAD}
  fi

  local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_BEHIND" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_BEHIND//NUM/$NUM_BEHIND}
  fi

  local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
  if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MERGING
  fi

  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_UNTRACKED
  fi

  if ! git diff --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MODIFIED
  fi

  if ! git diff --cached --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_STAGED
  fi

  if [[ -n $GIT_STATE ]]; then
    echo "$GIT_PROMPT_PREFIX$GIT_STATE$GIT_PROMPT_SUFFIX"
  fi

}

# If inside a Git repository, print its branch and state
git_prompt_string() {
  local git_where="$(parse_git_branch)"
  [ -n "$git_where" ] && echo "$GIT_PROMPT_SYMBOL$(parse_git_state)$GIT_PROMPT_PREFIX%{$fg[yellow]%}${git_where#(refs/heads/|tags/)}$GIT_PROMPT_SUFFIX"
}

# Set the right-hand prompt
RPS1='$(git_prompt_string)'
