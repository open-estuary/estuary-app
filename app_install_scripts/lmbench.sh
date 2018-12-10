#! /bin/bash

### Header info ###
## template: 	V01
## Author: 	XiaoJun x00467495
## name:	lmbench
## desc:	lmbench source code compile and install

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
package=lmbench3
version=3.0
filename=$package

## Selfdef Varis
# MY_SRC_DIR
# MY_SRC_TAR

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
	pr_tip "[clear] skipped"
	return 0
}

## Interface: install dependency
function install_depend()
{
	case $DISTRIBUTION in
		"CentOS")
			DEPENDENCE="wget tar gcc expect"
			pr_tip "[depend] $DEPENDENCE"
			yum --setopt=skip_missing_names_on_install=False install -y $DEPENDENCE
			pr_ok "[depend] ok"
			;;
		"Debian")
			DEPENDENCE="wget tar gcc expect"
			pr_tip "[depend] $DEPENDENCE"
			apt-get install -y $DEPENDENCE
			pr_ok "[depend] ok"
			;;	
	esac
	return $?
}

## Interface: download_src
function download_src()
{
	pr_tip "[download] $filename"
	wget http://www.bitmover.com/lmbench/lmbench3.tar.gz -O $filename.tar.gz
	ass_rst $? 0 "download failed"
	tar -xf $filename.tar.gz
	return #?
}

## Interface: software self test
## example: print version number, run any simple example
function selftest()
{
	pr_tip "[selftest] show results"
	make see
	return $?
}

## Interface: compile_and_install
function compile_and_install()
{
	
	pr_tip "[install]<version> $version"
	pr_tip "[install]<rm_git> "
	rm $filename.tar.gz	
	pr_tip "[install]<compile> NULL"

	patch -p0 < patch/lmbench/lmbench3-uclibc-llseek.patch
	ass_rst $? 0 "modify using patch failed"	

	cd $filename
	sed -i "s%$O/lmbench : ../scripts/lmbench bk.ver%$O/lmbench : ../scripts/lmbench%g" src/Makefile
	ass_rst $? 0 "modify makefile failed"
	cp ../patch/lmbench/gnu-os scripts/
	ass_rst $? 0 "copy gnu-os fail"

	expect<<-EOF
	set timeout 300000
	spawn make results
	expect "MULTIPLE COPIES"
	send "1\r"
	expect "Job placement selection"
	send "1\r"
	expect "MB"
	send "10\r"
	expect "SUBSET"
	send "\r"
	expect "FASTMEM"
	send "\r"
	expect "SLOWFS"
	send "\r"
	expect "DISKS"
	send "\r"
	expect "REMOTE"
	send "\r"
	expect "Processor mhz"
	send "\r"
	expect "FSDIR"
	send "\r"
	expect "Status output file"
	send "\r"
	expect "Mail results"
	send "n\r"
	expect "Leaving directory '${url}/src'"	
	EOF

	return $?
}

## Interface: rst_report
function rst_report()
{
	pr_err "[report]"
	return $rst
}

## Interface: finish install
function finish_install()
{
	pr_tip "[finish]<clean> skipped"
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
