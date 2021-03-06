#!/bin/bash

### Header info ###
## template: 	V01
## Author: 	zhangwangqun  zwx644970
## name:	qemu-kvm
## desc:	qemu-kvm source code compile and install

### RULE
## 1. update Header info
## 2. use pr_err/pr_tip/pr_ok/pr_info as print API
## 3. use ${ass_rst ret exp log} as result assert code
## 4. implement each Interface Functions if you need

### VARIS ###

# Color Macro Start 
MCOLOR_RED="\033[31m"
MCOLOR_GREEN="\033[32m"
MCOLOR_YELLOW="\033[33m"
MCOLOR_END="\033[0m"
# Color Macro End

SRC_URL=NULL
PKG_URL=NULL
DISTRIBUTION=NULL
rst=0


## Selfdef Varis
# MY_SRC_DIR=""
# MY_SRC_TAR=""

### internal API ###

function pr_err()
{
	if [ "$1"x == ""x ] ; then
		echo -e $MCOLOR_RED "Error!" $MCOLOR_END
	else
		echo -e $MCOLOR_RED "$1" $MCOLOR_END
	fi
}

function pr_tip()
{
	if [ "$1"x != ""x ] ; then
		echo -e $MCOLOR_YELLOW "$1" $MCOLOR_END
	fi
}

function pr_ok()
{
	if [ "$1"x != ""x ] ; then
		echo -e $MCOLOR_GREEN "$1" $MCOLOR_END
	fi
}

function pr_info()
{
	if [ "$1"x != ""x ] ; then
		echo " $1"
	fi
}

# assert result [  $1: check value; $2: expect value; $3: fail log  ]
function ass_rst() 
{
	if [ "$#"x != "3"x ] ; then
		pr_err "ass_rst param fail, only $#, expected 3"
		return 1
	fi

	if [ "$1"x != "$2"x ] ; then
		pr_err "$3"
		exit 1
	fi

	return 0
}

## Interface: get distribution
function check_distribution()
{
	if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
		DISTRIBUTION='CentOS'
	elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
		DISTRIBUTION='Debian'
	else
		DISTRIBUTION='unknown'
	fi

	pr_tip "Distribution : ${DISTRIBUTION}"

	return 0
}

## Interface: clear history files to prepare for reinstall files
function clear_history()
{
	pr_tip "[clear] skiped"
	return 0
}

## Interface: install dependency
function install_depend()
{
	pr_tip "[depend] skiped"
	return 0
	
}
## Interface: download_src
function download_src()
{

		if [ "$DISTRIBUTION"x == "Debian"x ] ; then
        apt-get install -y gcc libvirt* virtinst*
        ass_rst $? 0 "apt-get install failed!"
	elif [ "$DISTRIBUTION"x == "CentOS"x ] ; then
        yum --setopt=skip_missing_names_on_install=False install -y gcc qemu-kvm libvirt virt-install libguestfs-tools bridge-utils libvirt-python virt-manager
        ass_rst $? 0 "yum install failed!"
    else
        ass_rst 0 1 "dependence check failed!"
    fi

        pr_ok "[depend] OK"
		return 0
}

## Interface: compile_and_install
function compile_and_install()
{
	pr_tip "[compile]<install> skiped"
	return 0
}

## Interface: software self test
## example: print version number, run any simple example
function selftest()
{
	qemu-img --help
	ass_rst $? 0 "qemu_install failed!"
}

function uninstall()
{
	if [ "$DISTRIBUTION"x == "Debian"x ] ; then
        apt-get remove -y libvirt* virtinst*
        ass_rst $? 0 "apt-get remove failed!"
	elif [ "$DISTRIBUTION"x == "CentOS"x ] ; then
        yum --setopt=skip_missing_names_on_install=False remove -y qemu-kvm libvirt virt-install libguestfs-tools bridge-utils libvirt-python virt-manager
        ass_rst $? 0 "yum remove failed!"
    fi
}
	
### main code ###
function main()
{
	check_distribution
	ass_rst $? 0 "check_distribution failed!"
	
	if [ "$1"x == "uninstall"x ]; then
        uninstall
        ass_rst $? 0 "uninstall failed!"
        pr_ok "Software uninstall OK!"
        exit 0
    fi
	
	clear_history
	ass_rst $? 0 "clear_history failed"
	
	install_depend
	ass_rst $? 0 "install_depend failed!"
		
	download_src
	ass_rst $? 0 "download_src failed!"
	
	compile_and_install
	ass_rst $? 0 "compile_and_install failed!"
	
	selftest
	ass_rst $? 0 "selftest failed!"
	
	#finish_install
	#ass_rst $? 0 "finish_install failed"
}

pr_tip "-------- software compile and install start --------"
main $1
rst=$?

ass_rst $rst 0 "[FINAL] Software install,Fail!"

pr_ok " "
pr_ok "Software install OK!"

pr_tip "--------  software compile and install end  --------"
