#### CONFIG SPECIFIC VARIABLES ################################################
export C_SYS=`uname`
if [[ -e /goinfre ]]; then
	export C_SCHOOL=YES
fi
export C_PATH_TO_CONFIG=$HOME/.zsh_config

#### PATH and FPATH ###########################################################
test=$(echo "$PATH" | grep "$HOME/bin")
if [[ -z $test ]] ; then
	PATH=$HOME/bin:$PATH
fi

# yes it could had been at the end with the other stuff relate to 42 but it's
# the PATH so I put it at begining
if [[ "$C_SYS" = "Darwin" ]]; then
	test=$(echo "$PATH" | grep "$HOME/.brew/bin")
	if [[ -z $test ]] ; then
		PATH=$HOME/.brew/bin:$PATH
	fi
	export PATH

	# add completion provied by bin installed via brew
	if [[ -d "$HOME/.brew/share/zsh/site-functions" ]]; then
		fpath=($HOME/.brew/share/zsh/site-functions $fpath)
	fi

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
export LIB=~/libft

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
bindkey '\e[A' history-beginning-search-backward
bindkey '\e[B' history-beginning-search-forward
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward

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

#### MAC SPECIFIC STUFF #######################################################

if [[ $C_SYS == "Darwin" ]]; then
	# Alt-arrow to move from word to word
	bindkey "^[^[[C" forward-word
	bindkey "^[^[[D" backward-word
fi

#### 42 SCHOOL SPECIFIC STUFF #################################################

if [[ -n "$C_SCHOOL" ]]; then
	# 42 variables definition
	USER=`/usr/bin/whoami`
	export USER
	GROUP=`/usr/bin/id -gn $user`
	export GROUP
	MAIL="$USER@student.42.fr"
	export MAIL

	# fucking mac and their /Volume/<hdd_name>
	cd "`echo $PWD | sed 's:/Volumes/Data::'`"

	# Homebrew cache directory
	export HOMEBREW_CACHE=/tmp/$USER/brew_caches
	export HOMEBREW_TEMP=/tmp/$USER/brew_temp
	mkdir -p $HOMEBREW_CACHE $HOMEBREW_TEMP

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

	# reinstall brew and all the installed binaries
	function repare_brew ()
	{
		brew list > $HOME/.brew_list &&
			rm -rf $HOME/.brew && mkdir $HOME/.brew &&
			curl -L https://github.com/Homebrew/homebrew/tarball/master |
		tar xz --strip 1 -C $HOME/.brew &&
			mkdir -p $HOME/Library/Caches/Homebrew
		if [[ -f $C_PATH_TO_CONFIG/brew_tap ]]; then
			for line in `cat $C_PATH_TO_CONFIG/brew_tap`
			do
				if [[ ${line:0:1} != "#" ]]; then
					$HOME/.brew/bin/brew tap $line
				fi
			done
		fi
		$HOME/.brew/bin/brew install `cat $HOME/.brew_list` &&
			rm $HOME/.brew_list
	}

	function next ()
	{
		nb=$(basename `pwd` | grep "ex")
		if [[ -n "$nb" ]]; then
			if [[ -n "$1" ]]; then inc=$1; else inc=1; fi
			nb=$(expr `echo $nb | tr -d "[a-z]"` + $inc)
			if [[ $nb -lt 10 ]]
			then
				dir="../ex0$nb"
			else
				dir="../ex$nb"
			fi
			mkdir -p $dir
			cd $dir
		fi
	}

	function prev ()
	{
		nb=$(basename `pwd` | grep "ex")
		if [[ -n "$nb" ]]; then
			if [[ -n "$1" ]]; then dec=$1; else dec=1; fi
			nb=$(expr `echo $nb | tr -d "[a-z]"` - $dec)
			if [[ $nb -lt 0 ]]
			then
				dir="../ex00"
			elif [[ $nb -lt 10 ]]
			then
				dir="../ex0$nb"
			else
				dir="../ex$nb"
			fi
			cd $dir
		fi
	}
fi
