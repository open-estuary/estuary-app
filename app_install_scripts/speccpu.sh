#! /bin/bash

### Header info ###
## template: 	V01
## Author: 	LiHang l00465864
## name:	speccpu
## desc:	description

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
package=speccpu
version=2006
filename=$package$version
tmp_dir=NULL

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
	pr_tip "[clear] existed speccpu folder"
	if [ ! -d "$package" ] ; then
		pr_tip " "
	else
		rm -rf $package
		pr_tip "speccpu folder cleaned"
	fi
	return 0
}

## Interface: install dependency
function install_depend()
{
	case $DISTRIBUTION in
		"CentOS")
			DEPENDENCE="tar automake numactl gcc* libgfortran *cmp cmp* expect"
			pr_tip "[depend] DEPENDENCE"
			yum --setopt=skip_missing_names_on_install=False install -y $DEPENDENCE
			;;
		"Debian")
			DEPENDENCE="automake tar gcc  g++ numactl expect"
			pr_tip "[depend] $DEPENDENCE"
		    apt-get install -y $DEPENDENCE
			;;	
	esac
	ass_rst $? 0 "install dependence failed"
	return $?
}

## Interface: download_src
function download_src()
{
	pr_tip "[download] source code from $SRC_IP"
	SRC_IP=mahongxin@192.168.1.107
	SRC_PATH=/home/mahongxin/$filename.tar.gz
	PASSWD=123456
	mkdir $package
	tmp_dir=${PWD}
	expect<<-EOF
	set timeout 1200
	spawn scp $SRC_IP:$SRC_PATH ./ 
	expect {
    "yes/no" {send "yes\r";exp_continue}
	"password" {send "$PASSWD\r";}
	}
	expect eof
	EOF
	tar -xf $filename.tar.gz -C $package
	return 0
}

## Interface: software self test
## example: print version number, run any simple example
function selftest()
{
	pr_tip "[selftest] skipped"
	
	return $?
}

## Interface: compile_and_install
function compile_and_install()
{
	pr_tip "[install]<version> $version"
	pr_tip "[install]<rm_git> "
	rm $filename.tar.gz	
	pr_tip "[install]<compile> NULL"	
	grep -c "static bsd_signal_ret_t" $package/$filename/tools/src/make-3.82/main.c
	if [ "$?"x -ne "0"x ]; then
		pr_tip "make-3.82 source file already modified"
	else
		sed -i "s/static bsd_signal_ret_t/bsd_signal_ret_t/" $package/$filename/tools/src/make-3.82/main.c
	fi
	
	export FORCE_UNSAFE_CONFIGURE=1
	cd $package/$filename/tools/src
	echo y | ./buildtools
	ass_rst $? 0 "build failed"
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
	cd ${tmp_dir}
	rm -rf speccpu
	pr_ok "[finish]<clean> ok"
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
