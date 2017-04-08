#!/bin/bash

# PATHS
export CONF_PATH=$HOME/.zsh_config

# is it 42 school ?
if [[ `uname` == "Darwin" ]] && [[ -e '/goinfre' ]]; then
	export SCHOOL42=yes
fi

function usage()
{
	RED='\033[0;31m'
	NC='\033[0m'
	TMP_PP=`echo $CONF_PATH | tr '/' ':'`
	TMP_HOME=`echo $HOME | tr '/' ':'`
	CONF_PATH_C="\033[0;32m${TMP_PP/$TMP_HOME/~}"
	CONF_PATH_C=`echo $CONF_PATH_C | tr ':' '/'`
	echo "Usage: $0 [-h] [-f] [-u] [-b] [-p <git repository>]"
	echo -e "\t$RED-h$NC: display this help"
	echo -e "\t$RED-f$NC: apply force arg on command in the script if available"
	echo -e "\t$RED-u$NC: delete and recreate the symlink based on $CONF_PATH_C/ln$NC"
	echo -e "\t$RED-b$NC: install brew, tap repo in $CONF_PATH_C/brew_tap$NC and install $CONF_PATH_C/brew_apps$NC"
	echo -e "\t$RED-p$NC: clone your config in $CONF_PATH_C"$NC
	echo -e "\nThis config can work with a personal one in which you could put some specific files:"
	echo -e "\t"$RED"install.sh$NC: this script will be called when using -p arg"
	echo -e "\t"$RED"aliases   $NC: put your aliases in this file it will be sourced with zshrc"
	echo -e "\t"$RED"brew_app  $NC: all the apps to install with brew with -b arg"
	echo -e "\t"$RED"brew_tap  $NC: all the repo to add to brew"
	echo -e "\t"$RED"ln        $NC: all the symlink to create with -u arg"
	echo -e "\t"$RED"prompt    $NC: if you want to have a different prompt than the common one"
	echo -e "\t"$RED"zshrc     $NC: if you want to extand the common zshrc, do it it this file"
	echo -e "\nFor more complete explanation, report to \033[0;34mgithub.com/geam/config_common\033[0m"
	exit 0
}

function do_ln()
{
	unset SRC DEST
	if [[ -n "$1" ]]; then
		if [[ ${1:0:1} == "/" ]]; then
			SRC=$1
		else
			SRC="$CONF_PATH/$1"
		fi
	fi
	if [[ -n "$2" ]]; then
		if [[ ${2:0:1} == "/" ]]; then
			DEST=$2
		else
			DEST="$HOME/$2"
		fi
	fi
	if [[ -n "$SRC" ]] && [[ -n "$DEST" ]] && [[ -f "$SRC" ]]; then
		if [[ -e "$DEST" ]]; then
			if [[ "$INS_FORCE" == "OK" ]]; then
				rm -rf "$DEST"
			else
				mv "$DEST" "$DEST.back"
			fi
		fi
		ln -sf "$SRC" "$DEST"
	fi
}

# get the arg of the script
while test $# -gt 0
do
	if [[ "${1:0:2}" == '--' ]]
	then
		case $1 in
			--help)
				usage
				;;
			--force)
				INS_FORCE=OK
				;;
			*)
				echo "Unknown option $1"
				usage
				;;
		esac
	elif [[ "${1:0:1}" = '-' ]]
	then
		case $1 in
			-h)
				usage
				;;
			-f)
				INS_FORCE="OK"
				;;
			-u)
				INS_UP_LN="OK"
				;;
			-b)
				BREW="OK"
				;;
			*)
				echo "Unknown option $1"
				usage
				;;
		esac
	fi
	shift
done

if [[ `uname` == "Darwin" ]] && [[ "$BREW" == "OK" ]]; then
	BREW_CACHE="$HOME/Library/Caches/Homebrew"
	if [[ ! -e "$BREW_CACHE" ]]; then
		mkdir -p "$BREW_CACHE"
	fi
	/usr/local/bin/brew update
	if [[ $0 -ne 0 ]]; then
		mkdir $HOME/.brew &&
			curl -L https://github.com/Homebrew/homebrew/tarball/master |
		tar xz --strip 1 -C $HOME/.brew
	fi
	if [[ -f $CONF_PATH/brew_tap ]]; then
		for line in `cat $CONF_PATH/brew_tap`
		do
			if [[ ${line:0:1} != "#" ]]; then
				$HOME/.brew/bin/brew tap $line
			fi
		done
	fi
	$HOME/.brew/bin/brew update
	if [[ -f $CONF_PATH/brew_apps ]]; then
		$HOME/.brew/bin/brew install `cat $CONF_PATH/brew_apps`
		for line in `cat $CONF_PATH/brew_apps`
		do
			$HOME/.brew/bin/brew install $line ||
				echo "Error while installing $line"
		done
	fi
fi

if [[ -n "$INS_UP_LN" ]]; then
	rm -rf $HOME/.zshrc
	cd
	ln -sf $CONF_PATH/zshrc .zshrc
	cd - > /dev/null
	if [[ -f "$CONF_PATH/ln" ]]; then
		OIFS=$IFS
		for FILE in `cat "$CONF_PATH/ln"`
		do
			IFS=":"
			do_ln $FILE
			IFS=$OIFS
		done
	fi
	if [[ `uname` == "Darwin" ]]; then
		if [[ ! -e $HOME/.brew/share/site-functions ]]; then
			mkdir -p "$HOME/.brew/share/site-functions"
		fi
		rm -rf $HOME/.brew/share/zsh/site-functions/_brew
		ln -s $CONF_PATH/_brew $HOME/.brew/share/zsh/site-functions/_brew
	fi
fi

if [[ "$USER" != "arigowin" ]] && [[ "$USER" != "dolewski" ]]; then
	# remove my git config if it's not me
	sed -i.back '/git/d' $CONF_PATH/ln
fi

# # vim config
# CONFIG_VIM=$CONF_PATH/vim
# VIM_DEPOT=github.com:Arigowin/config_vim.git
# 
# if [[ -e $CONFIG_VIM ]]
# then
# 	rm -rf $CONFIG_VIM
# 	rm -f $HOME/.vimrc
# else
# 	CONFIG_PARENT=`dirname $CONFIG_VIM`
# 	CONFIG_PARENT=`dirname $CONFIG_PARENT`
# 	if [[ ! -e $CONFIG_PARENT ]]; then
# 		mkdir -p $CONFIG_PARENT
# 	fi
# fi
# 
# git clone "git@$VIM_DEPOT" $CONFIG_VIM
# # because some person keep using my personal config instead of doing their own,
# # they need to use the https version of this repo
# if [[ "$?" -ne 0 ]]; then
# 	git clone "https://$VIM_DEPOT" $CONFIG_VIM
# fi
# if [[ -e $CONFIG_VIM ]]; then
# 	cd $CONFIG_VIM && \
# 		cd && \
# 		ln -s $CONFIG_VIM/vimrc .vimrc && \
# 		vim +PlugInstall
# fi

if [[ -n $SCHOOL42 ]]; then
	# create script dir if it doesn't exist
	if [[ ! -e "$CONF_PATH/scripts" ]]; then
		mkdir "$CONF_PATH/scripts"
	fi

	# cause ~/Library/Caches are always sync even if you don't want..
	rm -rf $HOME/Library/Caches
	mkdir -p /tmp/$USER/Caches
	chmod 700 /tmp/$USER/Caches
	cd $HOME/Library
	ln -s /tmp/$USER/Caches

	# add font for osx
	cd
	git clone https://github.com/powerline/fonts temp_fonts
	cd temp_fonts
	mkdir ~/Library/Fonts
	./install.sh
	open /Applications/Font\ Book.app
fi
