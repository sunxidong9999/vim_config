###########################################################
# Filename:      vim_config.sh
# Author:        sunxidong
# Email:         sunxidong9999@gmail.com
# Created:       2022-06-12 10:49:40
# Last modified: 2023-04-23 15:12:31
# Description:
##########################################################

#!/bin/bash

. /etc/os-release

CURDIR=$PWD
CONFIGDIR=$CURDIR/config
VIMDIR=$HOME/.vim
VIMRC=$HOME/.vimrc
BUNDLEDIR=$VIMDIR/bundle
SYNTAXDIR=$VIMDIR/syntax
PROFILE=
INSTALL=

check_install() {
	if [ 0 = $? ]; then
		echo "Install $1 done."
	else
		echo "Install $1 failed."
		exit -1
	fi
	echo ""
}

check_os() {
	if echo $PRETTY_NAME | grep "[Cc]ent[Oo][Ss]" >/dev/null; then
		INSTALL="sudo yum install -y"
		PROFILE=~/.bashrc
	elif echo $PRETTY_NAME | grep "[Rr]ed.Hat.Enterprise" >/dev/null; then
		INSTALL="sudo yum install -y"
		PROFILE=~/.bashrc
	elif echo $PRETTY_NAME | grep "[Ff]edora" >/dev/null; then
		INSTALL="sudo dnf install -y"
		PROFILE=~/.bashrc
	elif echo $PRETTY_NAME | grep "[Uu]buntu" >/dev/null; then
		INSTALL="sudo apt install -y"
		PROFILE=~/.profile
	elif echo $PRETTY_NAME | grep "[Dd]ebian" >/dev/null; then
		INSTALL="sudo apt install -y"
		PROFILE=~/.profile
	else
		echo "Unknown OS - $PRETTY_NAME is not supported."
		exit -2
	fi
	echo "OS: $PRETTY_NAME"
	echo ""
}

downlad_golang() {
	echo "Installing golang ..."

	ARCH=`uname -m`

	if [ "$ARCH" == "x86_64" ]; then
		GOARCH=amd64
	else
		GOARCH=arm64
	fi
	GOVERSION=`curl https://go.dev/VERSION?m=text 2>/dev/null`
	if [ $? != 0 ]; then
		echo "Check golang version failed."
		exit -1
	fi
	GOFILE=$GOVERSION.linux-$GOARCH.tar.gz
	if [ ! -f "$GOFILE" ]; then
		echo "  Downloading Golang latest version($GOVERSION)"
		GO_DOWNLOAD_PATH=https://go.dev/dl/$GOFILE
		curl -Z -L $GO_DOWNLOAD_PATH -o $GOFILE
		#wget -c $GO_DOWNLOAD_PATH
		if [ $? != 0 ]; then
			echo "Download golang package failed."
			exit -1
		fi
	fi
	sudo tar xf $GOFILE -C /opt
	if [ $? != 0 ]; then
		echo "Install golang package failed."
		exit -1
	fi
}

check_golang() {
	if [ ! $(command -v go) ]; then
		echo "Golang package is not installed."
		echo "Visit https://go.dev/dl/"
		echo ""
		downlad_golang
	fi
}

set_golang_profile() {
	EXPORT1="export GOPROXY=https://proxy.golang.com.cn,direct"
	EXPORT2="export PATH=$PATH:/opt/go/bin:$HOME/go/bin"

	grep GOPROXY -nr $PROFILE 1>/dev/null 2>/dev/null
	if [ $? != 0 ]; then
		echo "" >> $PROFILE
		echo $EXPORT1 >> $PROFILE
		echo $EXPORT2 >> $PROFILE
	fi

	source $PROFILE
}

env_init() {
	mkdir -p $VIMDIR/bundle
	mkdir -p $VIMDIR/syntax

	check_os
	set_golang_profile
	check_golang
}

install_tools() {
	
	TOOLS="universal-ctags cscope vim git curl"
	for t in $TOOLS; do
		echo "Installing $t ..."
		$INSTALL $t 1>/dev/null 2>/dev/null
		check_install $t
	done
}

install_vundle() {
	echo "Installing vundle ..."
	VUNDLE=~/.vim/bundle/Vundle.vim
	if [ ! -d $VUNDLE ]; then
		git clone https://ghproxy.com/https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim 1>/dev/null 2>/dev/null
	else
		git -C $VUNDLE pull 1>/dev/null 2>/dev/null
	fi
	check_install vundle
}

install_configs() {
	echo "Installing configurations ..."
	cp $CONFIGDIR/vimrc ~/.vimrc -f
	cp $CONFIGDIR/c.vim ~/.vim/syntax/ -f
	cp $CONFIGDIR/go.vim ~/.vim/syntax/ -f
}

install_plugins() {
	echo "Installing plugins ..."
	vim -c PluginInstall -c qa
	vim -c GoInstallBinaries -c qa
}

env_init
install_tools
install_vundle
install_configs
install_plugins

