#! /bin/bash

### Header info ###
## template: 	V01
## Author: 	GongYinghua g00467629
## name:	PostgreSQL
## desc:	PostgreSQL source code compile and install

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

SRC_URL="https://ftp.postgresql.org/pub/source/v9.2.23/postgresql-9.2.23.tar.gz"
PKG_URL=NULL
DISTRIBUTION=NULL
rst=0
LOCAL_SRC_DIR="192.168.1.107/"
path=`pwd`

## Selfdef Varis
MY_SRC_DIR="postgresql-9.2.23"
MY_SRC_TAR="postgresql-9.2.23.tar.gz"

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

### Interface Functions ###
## Interface list:
##	check_distribution()
##	clear_history()
##	install_depend()
##	download_src()
##		download src
##		untar & cd topdir
##	compile_and_install()
##		toggle to the right version
##		remove git info
##		configure & compile
##		install
##	selftest()
##  finish_install()
##		remove files

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
	if [ "$DISTRIBUTION"x == "Debian"x ] ; then
		apt-get install -y make expect gcc libreadline-dev zlib1g-dev python-dev libxml2-dev
		ass_rst $? 0 "apt-get install failed!"
	elif [ "$DISTRIBUTION"x == "CentOS"x ] ; then
		yum install -y make gcc expect readline-devel zlib-devel python-devel libxml2-devel 
		ass_rst $? 0 "yum install failed!"
	else
		ass_rst 0 1 "dependence check failed!"
	fi
	pr_ok "[depend] OK"
	return 0
}
## Interface: download_src
function download_src()
{
	wget -T 10 -O ${MY_SRC_TAR} ${LOCAL_SRC_DIR}/${MY_SRC_TAR}
	if [ $? -ne 0 ]; then
		wget -O ${SRC_URL} --no-check-certificate 
		ass_rst $? 0 "wget ${SRC_URAL} failed!"
	fi
	tar -xvzf ${MY_SRC_TAR}
	ass_rst $? 0 "untar ${MY_SRC_TAR} failed!"
	cd ${MY_SRC_DIR}
	
	pr_ok "[download] OK!"
	return 0
}

## Interface: compile_and_install
function compile_and_install()
{
	pr_tip "[install]<version> skiped"
	pr_tip "[install]<rm_git> skiped"
	pr_tip "[install]<compile> skiped"
	
	./configure
		ass_rst $? 0 "configure failed!"

	make -j64
		ass_rst $? 0 "make failed!"

#		make check
#		ass_rst $? 0 "make check failed!"

	make install -j64
		ass_rst $? 0 "make install failed!"

	pr_ok "[install]<compile> OK"

	if [ "$DISTRIBUTION"x == "Debian"x ]; then
		pr_info ""
	elif [ "$DISTRIBUTION"x == "CentOS"x ]; then
		pr_info ""
	fi

	pr_ok "[install]<install> OK"
	return 0
}

## Interface: software self test
## example: print version number, run any simple example
function selftest()
{
	/usr/local/pgsql/bin/psql --version
	if [ $? -eq 0 ]
	then
		pr_info "install_OK"
	else
		pr_info "install_fail"
	fi
	
	pr_tip "[selftest] skiped"
	return 0
}

function uninstall()
{
	if [ "$DISTRIBUTION"x == "Debian"x ] ; then
		apt-get remove -y postgresql-libs
		ass_rst $? 0 "apt-get remove failed!"
	elif [ "$DISTRIBUTION"x == "CentOS"x ] ; then
		yum remove -y postgresql-libs
		ass_rst $? 0 "yum remove failed!"
	fi
	cd ${path}/postgresql-9.2.23 && make uninstall && make clean
	netstat -apn |grep 5432|grep -v grep|awk '{print $8}'|awk -F"/" '{print $1}'|xargs kill -9
	rm -rf ${path}/${MY_SRC_DIR} ${path}/${MY_SRC_TAR}
}
	
## Interface: finish install
#function finish_install()
#{
#
#	cd ../..
#	rm -rf ${MY_SRC_DIR} ${MY_SRC_TAR}
#
#	pr_ok "[finish]<clean> OK"
#	return 0
#}

### Dependence ###

### Compile and Install ###

### selftest ###

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
	
	#finstall
	#ass_rst $? 0 "finish_ish_ininstall failed"
}

pr_tip "-------- software compile and install start --------"
main $1
rst=$?

ass_rst $rst 0 "[FINAL] Software install,Fail!"

pr_ok " "
pr_ok "Software install OK!"

pr_tip "--------  software compile and install end  --------"
