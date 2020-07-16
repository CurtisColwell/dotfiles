#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

#------------------------------------------------------------------------------#
# App lists

# The 'core' is a collection of lightweight apps, these are installed when
# time is too short for a full install
CORE_APPS=(
	clang
	clang-format
	ctags
	expect
	git
	git-lfs
	gparted
	htop
	jstest-gtk
	nmap
	screen
	ssh
	tmux
	tree
	traceroute
	unzip
	vim
	xclip
)

MAIN_APPS=(
	android-tools-adb
	filezilla
	gimp
	openvpn
	python-pip
)

# Apps not usually needed on 'work' machines
ENTERTAINMENT_APPS=(
	steam
)

#------------------------------------------------------------------------------#
# Main entry point of script

main()
{
	sudo debconf-set-selections -v "$REPO_DIR/configs/debconf_selections.txt"

	case "$1" in
		-e)
			echo "Installing entertainment apps only ..."
			sudo apt-get -y install "${ENTERTAINMENT_APPS[@]}"
			;;
		-c)
			echo "Installing core apps only ..."
			sudo apt-get -y install "${CORE_APPS[@]}"
			;;
		-a)
			echo "Installing all apps ..."
			sudo apt-get -y install "${ENTERTAINMENT_APPS[@]}"
			# Fall through
			;;&
		*)
			echo "Installing core and main apps ..."
			default_install
			;;
	esac
}

default_install()
{
	sudo apt-get -y install "${CORE_APPS[@]}"
	sudo apt-get -y install "${MAIN_APPS[@]}"
}

not_installed() {
	res=$(dpkg-query -W -f='${Status}' "$1" 2>&1)
	if [[ "$res" == "install ok installed"* ]]; then
		echo "$1 is already installed"
		return 1
	fi
	return 0
}

main "$@"
