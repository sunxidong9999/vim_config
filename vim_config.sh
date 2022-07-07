#!/bin/sh
###########################################################
# Filename:      vim_config.sh
# Author:        sunxidong
# Email:         sunxidong9999@gmail.com
# Created:       2022-06-12 10:49:40
# Last modified: 2022-06-12 10:49:40
# Description:   
##########################################################

. /etc/os-release

CURDIR=$PWD
TMP=$CURDIR/tmp
CONFIGDIR=$CURDIR/configs
VIMDIR=$HOME/.vim
BUNDLEDIR=$VIMDIR/bundle
SYSINSTALL=

check_install() {
	if [ 0 = $? ]; then
		echo "install $1 done."
	else
		echo "install $1 failed."
	fi
	echo ""
}

check_os()
{
	if echo $PRETTY_NAME | grep "[Cc]ent[Oo][Ss]" >/dev/null; then
		SYSINSTALL="sudo yum install -y"
	elif echo $PRETTY_NAME | grep "[Rr]ed.Hat.Enterprise" >/dev/null; then
		SYSINSTALL="sudo yum install -y"
	elif echo $PRETTY_NAME | grep "[Uu]buntu" >/dev/null; then
		SYSINSTALL="sudo apt install -y"
	elif echo $PRETTY_NAME | grep "[Dd]ebian" >/dev/null; then
		SYSINSTALL="sudo apt install -y"
	elif echo $PRETTY_NAME | grep "[Ff]edora" >/dev/null; then
		SYSINSTALL="sudo dnf install -y"
	else
		echo "Unknown OS - $PRETTY_NAME is not supported."
		exit 0
	fi
	echo "OS: $PRETTY_NAME"
	echo ""
	#echo "install command: $SYSINSTALL"
}

install_tools() {

	echo "Install universal-ctags ..."
	$SYSINSTALL universal-ctags 1>/dev/null 2>/dev/null
	check_install universal-ctags

	echo "Install cscope ..."
	$SYSINSTALL cscope 1>/dev/null 2>/dev/null
	check_install cscope
}

env_init() {
	if [ -d $TMP ]; then
		rm -rf $TMP
	fi
	mkdir -p $VIMDIR/autoload
	mkdir -p $VIMDIR/bundle
	mkdir -p $VIMDIR/syntax

	mkdir -p $TMP
	check_os
	install_tools
}

install_pathogen() {
	echo "install pathogen ..."

	git -C $TMP clone https://github.com/tpope/vim-pathogen 1>/dev/null 2>/dev/null
	check_install pathogen

	cp $TMP/vim-pathogen/autoload $VIMDIR/ -rf
	rm $TMP/ -rf
}

install_tagbar() {
	echo "install tagbar ..."

	PLUGIN=$BUNDLEDIR/tagbar
	SRC=https://github.com/majutsushi/tagbar

	if [ -d $PLUGIN ]; then
		git -C $PLUGIN config pull.rebase true
		git -C $PLUGIN pull
	else
		git -C $BUNDLEDIR clone $SRC 1>/dev/null 2>/dev/null
	fi
	check_install tagbar
}

install_nerdtree() {
	echo "install nerdtree ..."

	PLUGIN=$BUNDLEDIR/nerdtree
	SRC=https://github.com/scrooloose/nerdtree
	if [ -d $PLUGIN ]; then
		git -C $PLUGIN config pull.rebase true
		git -C $PLUGIN pull
	else
		git -C $BUNDLEDIR clone $SRC 1>/dev/null 2>/dev/null
	fi
	check_install nerdtree
}

install_vimgo() {
	echo "install vim-go ..."

	PLUGIN=$BUNDLEDIR/vim-go
	SRC=https://github.com/fatih/vim-go

	if [ -d $PLUGIN ]; then
		git -C $PLUGIN config pull.rebase true
		git -C $PLUGIN pull
	else
		git -C $BUNDLEDIR clone $SRC 1>/dev/null 2>/dev/null
	fi
	check_install vim-go 

	echo "config vim-go ..."
	vim -c ":GoInstallBinaries" -c ":q"
	check_install config-vim-go 
}

install_multiple_cursors() {
	echo "install multiple-cursors ..."

	PLUGIN=$BUNDLEDIR/vim-multiple-cursors
	SRC=https://github.com/terryma/vim-multiple-cursors

	if [ -d $PLUGIN ]; then
		git -C $PLUGIN config pull.rebase true
		git -C $PLUGIN pull
	else
		git -C $BUNDLEDIR clone $SRC 1>/dev/null 2>/dev/null
	fi
	check_install multiple-cursors
}

install_vimclosetag() {
	echo "install vim-closetag ..."

	PLUGIN=$BUNDLEDIR/vim-closetag
	SRC=https://github.com/alvan/vim-closetag

	if [ -d $PLUGIN ]; then
		git -C $PLUGIN config pull.rebase true
		git -C $PLUGIN pull
	else
		git -C $BUNDLEDIR clone $SRC 1>/dev/null 2>/dev/null
	fi
	check_install vim-closetag
}

# tutorial: https://raw.githubusercontent.com/mattn/emmet-vim/master/TUTORIAL
install_emmet() {
	echo "install emmet-vim ..."

	PLUGIN=$BUNDLEDIR/emmet-vim
	SRC=https://github.com/mattn/emmet-vim

	if [ -d $PLUGIN ]; then
		git -C $PLUGIN config pull.rebase true
		git -C $PLUGIN pull
	else
		git -C $BUNDLEDIR clone $SRC 1>/dev/null 2>/dev/null
	fi
	check_install emmet-vim
}

install_configs() {
	echo "install configs ..."
	cp $CONFIGDIR/*.vim $VIMDIR/syntax/ -rf
	cp $CONFIGDIR/vimrc $HOME/.vimrc -f
	check_install configs
}

echo ""

env_init
install_pathogen
install_tagbar
install_nerdtree
install_vimgo
install_multiple_cursors
install_vimclosetag
install_emmet
install_configs
