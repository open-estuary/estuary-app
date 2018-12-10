#! /bin/bash

### Header info ###
## template: 	V01
## Author: 	XiaoJun x00467495
## name:	bcc-tools
## desc:	bcc_tools source code compile and install

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
package=bcc
version=0.7.0
filename=$package-$version
num_of_cores=1
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
	pr_tip "[clear] skiped"
	return 0
}

## Interface: install dependency
function install_depend()
{
	case $DISTRIBUTION in
		"CentOS")
			DEPENDENCE="wget cmake3 tar gcc gcc-c++ python2-pip bison flex elfutils-libelf-devel"
			pr_tip "[depend] $DEPENDENCE"
			yum --setopt=skip_missing_names_on_install=False install -y $DEPENDENCE
			ass_rst $? 0 "install dependence using yum failed"
			
			DEPENDENCE_KERNEL="kernel-headers-$(uname -r) kernel-tools-$(uname -r) kernel-tools-libs-$(uname -r) kernel-devel-$(uname -r)"
			yum --setopt=skip_missing_names_on_install=False install -y $DEPENDENCE_KERNEL
			ass_rst $? 0 "install dependence using yum failed"
			
			pr_tip "[depend] luajit"
			LUA=LuaJIT-2.1.0-beta3
			wget http://luajit.org/download/LuaJIT-2.1.0-beta3.tar.gz -O $LUA
			ass_rst $? 0 "download luajit source failed"
			tar -xf $LUA
			cd $LUA
			make -j$num_of_cores PREFIX=/usr 
			ass_rst $? 0 "build lua failed"
			make install PREFIX=/usr
			ass_rst $? 0 "install lua failed"
			ln -sf luajit-2.1.0-beta3 /usr/local/bin/luajit
			cd -
			rm -rf $LUA
			
			pr_tip "[depend] netperf"
			NETPERF=netperf-2.7.0
			wget https://github.com/HewlettPackard/netperf/archive/netperf-2.7.0.tar.gz -O $NETPERF --no-check-certificate
			ass_rst $? 0 "download netperf source failed"
			tar -xf $NETPERF
			cd netperf-$NETPERF
			./configure -build=alpha 
			ass_rst $? 0 "configure netperf failed"
			make -j$num_of_cores
			ass_rst $? 0 "build netperf failed"
			make install
			ass_rst $? 0 "install netperf failed"
			cd -
			rm -rf netperf-$NETPERF
			
			pr_tip "[depend] pyroute2"
			pip install pyroute2
			ass_rst $? 0 "install pyroute2 failed"
			
			pr_tip "[depend] llvm"
			wget http://releases.llvm.org/6.0.0/llvm-6.0.0.src.tar.xz -O llvm-6.0.0.src.tar.xz
			ass_rst $? 0 "download llvm source failed"
			tar -xf llvm-6.0.0.src.tar.xz
			wget http://releases.llvm.org/6.0.0/cfe-6.0.0.src.tar.xz -O cfe-6.0.0.src.tar.xz
			ass_rst $? 0 "download clang source failed"
			tar -xf cfe-6.0.0.src.tar.xz
			mv cfe-6.0.0.src llvm-6.0.0.src/tools
			wget http://llvm.org/releases/6.0.0/compiler-rt-6.0.0.src.tar.xz  -O compiler-rt-6.0.0.src.tar.xz
			ass_rst $? 0 "download compiler-rt source failed"
			tar -xf compiler-rt-6.0.0.src.tar.xz
			mv compiler-rt-6.0.0.src llvm-6.0.0.src/projects		
			mkdir llvm-build
			cd llvm-build
			cmake3 -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD="BPF;X86;AArch64" ../llvm-6.0.0.src
			ass_rst $? 0 "llvm configure failed"
			make -j$num_of_cores
			ass_rst $? 0 "llvm build failed"
			make install
			ass_rst $? 0 "llvm install failed"
			cd -
			rm -rf llvm-build llvm-6.0.0.src
			pr_ok "[depend] ok"
			;;
		"Debian")
			DEPENDENCE="wget tar gcc g++ linux-image-$(uname -r) linux-headers-$(uname -r) \
			debhelper cmake libllvm6.0 llvm-6.0-dev libclang-6.0-dev \
			libelf-dev bison flex libedit-dev clang-format-6.0 python python-netaddr \
			python-pyroute2 arping iperf netperf ethtool \
			devscripts zlib1g-dev libfl-dev"
			pr_tip "[depend] $DEPENDENCE"
			
			DEB_LIST=/etc/apt/sources.list.d/deb_temp.list
			cat>$DEB_LIST<<-EOF
			deb http://httpredir.debian.org/debian/ stretch main non-free
			deb-src http://httpredir.debian.org/debian/ stretch main non-free
			deb http://httpredir.debian.org/debian stretch-backports main
			deb-src http://httpredir.debian.org/debian stretch-backports main
			EOF
			apt-get update
			apt-get install -y $DEPENDENCE
			ass_rst $? 0 "install dependence using apt failed"
			apt-get -t stretch-backports install luajit libluajit-5.1-dev
			ass_rst $? 0 "install luajit failed"
			rm $DEB_LIST
			pr_ok "[depend] ok"
			;;
	esac
	return $?
}

## Interface: download_src
function download_src()
{
	pr_tip "[download] $filename"
	wget https://github.com/iovisor/bcc/archive/v0.7.0.tar.gz -O $filename.tar.gz --no-check-certificate
	ass_rst $? 0 "download failed"
	pr_ok "[download] ok"
	return 0
}

## Interface: software self test
## example: print version number, run any simple example
function selftest()
{
	pr_tip "[selftest] check version"
	
	return $?
}

## Interface: compile_and_install
function compile_and_install()
{
	pr_tip "[install]<version> $version"
	pr_tip "[install]<rm_git> "
	tar -xf $filename.tar.gz
	rm $filename.tar.gz	
	pr_tip "[install]<compile> NULL"
	pr_tip "[install]<install>"
	cd $filename
	if [ ! -d "build" ]; then
		mkdir build
	else 
		rm -rf build
		mkdir build
	fi
	cd build
	if [ "$DISTRIBUTION"x == "Debian"x ] ; then
		cmake .. -DCMAKE_INSTALL_PREFIX=/usr
	elif [ "$DISTRIBUTION"x == "CentOS"x ] ; then
		cmake3 .. -DCMAKE_INSTALL_PREFIX=/usr
	fi
	ass_rst $? 0 "bcc configure failed"
	make -j$num_of_cores
	ass_rst $? 0 "bcc build failed"
	make install
	ass_rst $? 0 "bcc install failed"
	cd ../..
	rm -rf $filename
	pr_ok "[install] ok"
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
