#### CONFIG SPECIFIC VARIABLES ################################################
export C_SYS=`uname`
export C_PATH_TO_CONFIG=$HOME/.zsh_config

#### PATH and FPATH ###########################################################
test=$(echo "$PATH" | grep "$HOME/bin")
if [[ -z $test ]] ; then
	PATH=$HOME/bin:$PATH
fi

#### ZSH CONFIG ###############################################################
# zsh history
HISTFILE=~/.zsh_history
SAVEHIST=5000
HISTSIZE=5000
setopt inc_append_history
setopt share_history

# previous/next word with ctrl + arrow
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# delete key
bindkey "\e[3~"   delete-char

# better autocomplete
autoload -U compinit && compinit

# autocomplete menu
zstyle ':completion:*' menu select

# prompt color
autoload -U colors && colors

#### LOAD STUFF ########################################################
# Load prompt file
source "$C_PATH_TO_CONFIG/prompt"

# add prompt_hook to precmd hook list
[[ -z $precmd_functions ]] && precmd_functions=()
precmd_functions=($precmd_functions prompt_hook)

# Load global aliases
source $C_PATH_TO_CONFIG/aliases

# Add personal scripts to path
if [[ -d "$C_PATH_TO_CONFIG/scripts" ]]; then
	test=$(echo "$PATH" | grep "$C_PATH_TO_CONFIG/scripts")
	if [[ -z $test ]] ; then
		PATH="$C_PATH_TO_CONFIG/scripts:$PATH"
	fi
fi

#### CONFIG STUFF ########################################################
# Tmux command history
bindkey '^R' history-incremental-search-backward
bindkey -e
export LC_ALL=en_US.UTF-8

# default editor
editor=`which nvim 2> /dev/null`
if [[ "$?" -eq 0 ]]
then
	EDITOR=$editor
else
	editor=`which vim 2> /dev/null`
	if [[ "$?" -eq 0 ]]
	then
		EDITOR=$editor
	else
		EDITOR=/usr/bin/nano
	fi
fi
export EDITOR

# default pager
editor=`which less 2> /dev/null`
PAGER=$editor
export PAGER

# Reglage du terminal
if [ "$SHLVL" -eq 1 ]; then
	TERM=xterm-256color
fi

# search in history based on what is type
# bindkey '\e[A' history-beginning-search-backward
# bindkey '\e[B' history-beginning-search-forward
# bindkey '^[[A' history-beginning-search-backward
# bindkey '^[[B' history-beginning-search-forward
bindkey "$terminfo[kcuu1]" history-beginning-search-backward
bindkey "$terminfo[kcud1]" history-beginning-search-forward

# ctrl + arrow in archlinux
bindkey '^[Od' backward-word
bindkey '^[Oc' forward-word

# Definition des couleurs
if [ -f $HOME/.ls_colors ]; then
	source $HOME/.ls_colors
fi

# Couleurs pour le man
man()
{
	env \
		LESS_TERMCAP_mb=$(printf "\e[1;31m") \
		LESS_TERMCAP_md=$(printf "\e[1;31m") \
		LESS_TERMCAP_me=$(printf "\e[0m") \
		LESS_TERMCAP_se=$(printf "\e[0m") \
		LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
		LESS_TERMCAP_ue=$(printf "\e[0m") \
		LESS_TERMCAP_us=$(printf "\e[1;32m") \
		man "$@"
	}

# OPAM configuration
. $HOME/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true

# MinilibX
export PKG_CONFIG_PATH=$HOME/minilibx_linux

# Tex
PATH=/usr/local/texlive/2020/bin/x86_64-linux:$PATH

<<<<<<< HEAD
# SPRING CLI
export SPRING_HOME=/home/arigowin/.spring
PATH=$SPRING_HOME/bin:$PATH

# 42 Header config
export USER="dolewski"
export MAIL="dolewski@student.42.fr"
=======
	# Libft
	export LIB=~/libft

	# Homebrew cache directory
	export HOMEBREW_CACHE=/tmp/$USER/brew_caches
	export HOMEBREW_TEMP=/tmp/$USER/brew_temp
	mkdir -p $HOMEBREW_CACHE $HOMEBREW_TEMP

	# 42AI Ateliers-ml
	export PATH="/sgoinfre/goinfre/Perso/dolewski/anaconda3/bin:$PATH"

	# update symlink in case of zsf change
	if [[ ! -f $HOME/.old_home ]]; then
		echo $HOME > $HOME/.old_home
	fi
	OLD_HOME=$(cat $HOME/.old_home)
	if [[ "$OLD_HOME" != "$HOME" ]]; then
		echo $HOME > $HOME/.old_home
		$C_PATH_TO_CONFIG/install.sh -u
		echo "+------------------------------------------------+"
		echo "|                                                |"
		echo "|             /!\\ You've changed zsf             |"
		echo "|                                                |"
		echo "| If you encounter issue with binaries installed |"
		echo "| via brew, you should use the command :         |"
		echo "| repare_brew                                    |"
		echo "| /!\\ This command may take some time            |"
		echo "+------------------------------------------------+"
	fi
>>>>>>> 2f015aa224025ed7e1d0ed9e4c4329146bb64efd

# Cargo
PATH=$HOME/.cargo/bin:$PATH

# Make
export MAKEFLAGS='-j 8'


# VTE for Termite
if [[ $TERM == xterm-termite ]]; then
  . /etc/profile.d/vte.sh
  __vte_osc7
fi

# opam configuration
test -r /Users/dolewski/.opam/opam-init/init.zsh && . /Users/dolewski/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true
