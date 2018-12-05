#! /bin/bash

### Header info ###
## template:    V01
## Author:      XiaoJun x00467495
## name:        systemtap
## desc:        systemtap source code compile and install

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

SRC_URL="git://sourceware.org/git/systemtap.git"
PKG_URL=NULL
DISTRIBUTION=NULL
rst=0

## Selfdef Varis
MY_SRC_DIR=systemtap
# MY_SRC_TAR
MY_CENTOS_DEPEND="kernel kernel-devel kernel-debuginfo elfutils-devel"
MY_DEBIAN_DEPEND="linux-image-4.19.0-8-arm64-dbg linux-headers-4.19.0-8-arm64 gettext libdw-dev"

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

# assert result [  $1: check value; $2: expect value; $3 fail log  ]
function ass_rst()
{
		if [ "$#"x != "3"x ] ; then
				pr_err "ass_rst param faill, only $#, expected 3"
				return 1
		fi

		if [ "$1"x != "$2"x ] ; then
				pr_err "$3"
				exit 1
		fi

		return 0
}

### Interface Functions ###
## Interface list:
##      check_distribution()
##      clear_history()
##      install_depend()
##      download_src()
##              download src
##              untar & cd topdir
##      compile_and_install()
##              toggle to the right version
##              remove git info
##              configure & compile
##              install
##      selftest()
##  finish_install()
##              remove files

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
	rm -rf ${MY_SRC_DIR}

	pr_ok "[clear] OK"
	return 0
}

## Interface: install dependency
function install_depend()
{
	if [ ! -f /usr/sr/kernels/`uname -r`/arch/arm64/kernel/modules.lds ] ; then
		cp patch/systemtap/module.lds /usr/src/kernels/`uname -r`/arch/arm64/kernel/
	fi

	if [ "$DISTRIBUTION"x == "Debian"x ] ; then
		apt-get install -y ${MY_DEBIAN_DEPEND}
		ass_rst $? 0 "install depend failed!"
	elif [ "$DISTRIBUTION"x == "CentOS"x ] ; then
		yum install -y ${MY_CENTOS_DEPEND} --setopt=skip_missing_names_on_install=False
		ass_rst $? 0 "install depend failed!"
	fi


	pr_tip "[depend] skiped"
	return 0
}

## Interface: download_src
function download_src()
{

	git clone ${SRC_URL}
	ass_rst $? 0 "git clone failed!"

	cd ${MY_SRC_DIR}
	ass_rst $? 0 "cd ${MY_SRC_DIR} failed!"

	pr_ok "[download] OK"
	return 0
}

## Interface: compile_and_install
function compile_and_install()
{
	git reset --hard dd57c73873b184b329f47bd186fa77e6d842eac0
	pr_ok "[install]<version> OK!"

	rm -rf .git
	pr_ok "[install]<rm_git> OK!"

	./configure
	ass_rst $? 0 "configure failed!"

	make
	ass_rst $? 0 "make failed!"

	make check
	ass_rst $? 0 "make check failed!"

	make install
	ass_rst $? 0 "make install failed!"

	pr_ok "[install]<compile> OK"

	if [ "$DISTRIBUTION"x == "Debian"x ] ; then
		pr_info ""
	elif [ "$DISTRIBUTION"x == "CentOS"x ] ; then
		pr_info ""
	fi

	pr_tip "[install]<install>"
	return 0
}

## Interface: software self test
## example: print version number, run any simple example
function selftest()
{
	stap -ve 'probe begin { print("ok") exit()}'
	ass_rst $? 0 "test stap failed!"

	pr_ok "[selftest] OK"
	return 0
}

## Interface: finish install
function finish_install()
{
	cd ../
	rm -rf ${MY_SRC_DIR}

	pr_ok "[finish]<clean> OK"
	return 0
}

### Dependence ###

### Compile and Install ###

### selftest ###

### main code ###
function main()
{
	check_distribution
	ass_rst $? 0 "check_distribution failed!"

	clear_history
	ass_rst $? 0 "clear_history failed!"

	install_depend
	ass_rst $? 0 "install_depend failed!"

	download_src
	ass_rst $? 0 "download_src failed!"

	compile_and_install
	ass_rst $? 0 "compile_and_install failed!"

	selftest
	ass_rst $? 0 "selftest failed!"

	finish_install
	ass_rst $? 0 "finish_install failed"
}

pr_tip "-------- software compile and install start --------"
main
rst=$?

ass_rst $rst 0 "[FINAL] Software install,Fail!"

pr_ok " "
pr_ok "Software install OK!"

pr_tip "--------  software compile and install end  --------"

