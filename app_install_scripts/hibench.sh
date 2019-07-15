#! /bin/bash

### Header info ###
## template: 	V01
## Author: 	LiHang l00465864
## name:	demo
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
package=HiBench
version=7.0
filename=$package-$version

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
	pr_tip "[clear] existed source files"
	if [ -d HiBench-$filename ] ; then 
		rm -rf HiBench-$filename
		pr_tip "existed source files cleared"
	else
		pr_tip ""
	fi
	return 0
}

## Interface: install dependency
function install_depend()
{
	case $DISTRIBUTION in
		"CentOS")
			DEPENDENCE="wget tar maven"
			pr_tip "[depend] $DEPENDENCE"
		    yum --setopt=skip_missing_names_on_install=False install -y $DEPENDENCE
			;;	
		"Debian")
			DEPENDENCE="wget tar maven"
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
	pr_tip "[download] $filename"
	wget https://github.com/intel-hadoop/HiBench/archive/HiBench-7.0.tar.gz -O $filename.tar.gz
	ass_rst $? 0 "download failed"
	tar -xf $filename.tar.gz	
	return $?
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
	pr_tip "[install]<install>"
	grep -c "http:\/\/maven.aliyun.com\/nexus\/content\/groups\/public\/" /etc/maven/settings.xml
	if [ "$?"x -eq "0"x ]; then
		pr_tip "sources mirror test pass"
	else
		sed -i "/<\/mirrors>/i\<mirror>\n<id>big<\/id>\n<mirrorOf>*<\/mirrorOf>\n<name>data<\/name>\n<url>http:\/\/maven.aliyun.com\/nexus\/content\/groups\/public\/<\/url>\n<\/mirror>" /etc/maven/settings.xml
	fi
	cd HiBench-$filename
	mkdir hadoopbench/sql/target
	wget http://archive.apache.org/dist/hive/hive-0.14.0/apache-hive-0.14.0-bin.tar.gz -P hadoopbench/sql/target
	ass_rst $? 0 "download sql dependece failed"
	mkdir hadoopbench/mahout/target
	wget http://archive.cloudera.com/cdh5/cdh/5/mahout-0.9-cdh5.1.0.tar.gz -P hadoopbench/mahout/target
	ass_rst $? 0 "download mahout dependece failed"
	wget http://archive.apache.org/dist/mahout/0.11.0/apache-mahout-distribution-0.11.0.tar.gz -P hadoopbench/mahout/target
	ass_rst $? 0 "download mahout dependece failed"
	mkdir hadoopbench/nutchindexing/target
	wget http://archive.apache.org/dist/nutch/apache-nutch-1.2-bin.tar.gz -P hadoopbench/nutchindexing/target
	ass_rst $? 0 "download nutchindexing dependece failed"
	mvn -Dspark=2.1 -Dscala=2.11 package -DskipTests
	ass_rst $? 0 "install failed"
	return 0
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
	pr_tip "[finish]<clean> skiped"
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
