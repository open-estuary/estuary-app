#! /bin/bash

### Header info ###
## template: 	V02
## Author: 	XiaoJun x00467495
## name:	APP
## desc:	APP package install and uninstall

### RULE
## 1. update Header info
## 2. use pr_err/pr_tip/pr_ok/pr_info as print API
## 3. use ${ass_rst ret exp log} as result assert code
## 4. implement each Interface Functions if you need
## 5. $1: option，(‘uninstall’ only)

### VARIS ###

# Color Macro Start 
MCOLOR_RED="\033[31m"
MCOLOR_GREEN="\033[32m"
MCOLOR_YELLOW="\033[33m"
MCOLOR_END="\033[0m"
# Color Macro End
GCC_CENTOS_DEPEND_PKGS="gcc automake autoconf libtool m4 zlib-devel gcc-c++ lsof"
GCC_DEBIAN_DEPEND_PKGS="gcc m4 ruby zlib1g.dev g++ build-essential autoconf libtool automake lsof"
MONGODB_CENTOS_DEPEND_PKGS="unzip python-devel libcurl-devel libcurl-dev openssl openssl-devel python-setuptools.noarch libxml2-devel libxml2 libstdc++-static lzip glibc-static libffi-devel"
MONGODB_DEBIAN_DEPEND_PKGS="unzip python-dev libcurl4-openssl-dev python-setuptools libxml2-dev libxml2 libstdc++-6-dev lzip libffi-dev"
CPU_NUM=`nproc`
GMP='gmp-6.1.0.tar.xz'
MPFR='mpfr-3.1.4.tar.xz'
MPC='mpc-1.0.3.tar.gz'
GCC='gcc-7.2.0.tar.xz'
SIX='six-1.12.0.tar.gz'
PYYAML='PyYAML-5.1.tar.gz'
TYPING='typing-3.6.6.tar.gz'
CHEETAH='Cheetah-2.4.4.tar.gz'
MONGODB='mongo-r4.0.3.zip'
PIP='pip-19.0.2.tar.gz'
SETUPTOOLS='setuptools-41.0.1.zip'
MARKDOWN='Markdown-3.1.1-py2.py3-none-any.whl'
GCC_URL='https://mirrors.tuna.tsinghua.edu.cn/gnu/gcc/gcc-7.2.0/gcc-7.2.0.tar.xz'
BASE_URL='https://mirrors.tuna.tsinghua.edu.cn/gnu/'
SIX_URL='https://files.pythonhosted.org/packages/dd/bf/4138e7bfb757de47d1f4b6994648ec67a51efe58fa907c1e11e350cddfca/six-1.12.0.tar.gz'
PYYAML_URL='https://files.pythonhosted.org/packages/9f/2c/9417b5c774792634834e730932745bc09a7d36754ca00acf1ccd1ac2594d/PyYAML-5.1.tar.gz'
TYPING_URL='https://files.pythonhosted.org/packages/bf/9b/2bf84e841575b633d8d91ad923e198a415e3901f228715524689495b4317/typing-3.6.6.tar.gz'
CHEETAH_URL='https://files.pythonhosted.org/packages/cd/b0/c2d700252fc251e91c08639ff41a8a5203b627f4e0a2ae18a6b662ab32ea/Cheetah-2.4.4.tar.gz'
MONGODB_URL='http://github.com/mongodb/mongo/archive/r4.0.3.zip'
PIP_URL='https://files.pythonhosted.org/packages/4c/4d/88bc9413da11702cbbace3ccc51350ae099bb351febae8acc85fec34f9af/pip-19.0.2.tar.gz'
SETUPTOOLS_URL='https://files.pythonhosted.org/packages/1d/64/a18a487b4391a05b9c7f938b94a16d80305bf0369c6b0b9509e86165e1d3/setuptools-41.0.1.zip'
MARKDOWN_URL='https://files.pythonhosted.org/packages/c0/4e/fd492e91abdc2d2fcb70ef453064d980688762079397f779758e055f6575/Markdown-3.1.1-py2.py3-none-any.whl'
LOCAL_SRC_DIR='192.168.1.107/'
SRC_URL=NULL
PKG_URL=NULL
DISTRIBUTION=NULL
rst=0
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
##	if $1=="uninstall"
##		uninstall()
##		exit 0
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
        pr_info "install using apt-get"
        apt-get install -y ${GCC_DEBIAN_DEPEND_PKGS}
        pr_ok "[compile]<install> ok"
        apt-get install -y ${MONGODB_DEBIAN_DEPEND_PKGS}
        ass_rst $? 0 "install mongodb depend failed"
        pr_ok "[install]<mongodb_depend> ok"

    elif [ "$DISTRIBUTION"x == "CentOS"x ] ; then
        pr_info "install using yum"
        yum install -y ${GCC_CENTOS_DEPEND_PKGS}
        ass_rst $? 0 "install gcc depend failed"
        pr_ok "[install]<gcc_depend> ok"
        yum install -y ${MONGODB_DEBIAN_DEPEND_PKGS}
        ass_rst $? 0 "install mongodb depend failed"
        pr_ok "[install]<mongodb_depend> ok"
    fi
	return 0
}

## Interface: download_src
function download_src()
{
    #下载gcc gmp
    wget -O ${GMP} ${BASE_URL}gmp/${GMP}
    ass_rst $? 0 "download gmp failed"
    pr_ok "[download]<gmp> ok"
    #下载gcc mpfr
    wget -O ${MPFR} ${BASE_URL}mpfr/${MPFR}
    ass_rst $? 0 "download mpfr failed"
    pr_ok "[download]<mpfr> ok"
    #下载gcc mpc
    wget -O ${MPC} ${BASE_URL}mpc/${MPC}
    ass_rst $? 0 "download mpc failed"
    pr_ok "[download]<mpc> ok"
    #下载gcc7.2.0
    wget -T 10 -O ${GCC} ${LOCAL_SRC_DIR}/${GCC}
    if [ $? -ne 0 ]; then
        wget -O ${GCC} "${GCC_URL}"
        ass_rst $? 0 "download gcc7.2 failed"
    fi
    pr_ok "[download]<gcc7.2> ok"
    #下载mongodb pip 19.0.2
    wget -O ${PIP} ${PIP_URL}
    ass_rst $? 0 "download pip failed"
    pr_ok "[download]<pip> ok"
    #下载mongodb setuptools 41.0.1
    wget -O ${SETUPTOOLS} ${SETUPTOOLS_URL}
    ass_rst $? 0 "download setuptools failed"
    pr_ok "[download]<setuptools> ok"
    #下载mongodb Markdown 3.1.1
    wget -O ${MARKDOWN} ${MARKDOWN_URL}
    ass_rst $? 0 "download markdown failed"
    pr_ok "[download]<markdown> ok"
    #下载mongodb six 1.12.0
    wget -O ${SIX} ${SIX_URL}
    ass_rst $? 0 "download six failed"
    pr_ok "[download]<six> ok"
    #下载mongodb pyyaml 5.1
    wget -O ${PYYAML} ${PYYAML_URL}
    ass_rst $? 0 "download pyyaml failed"
    pr_ok "[download]<pyyaml> ok"
    #下载mongodb typing 3.6.6
    wget -O ${TYPING} ${TYPING_URL}
    ass_rst $? 0 "download typing failed"
    pr_ok "[download]<typing> ok"
    #下载mongodb cheetah 2.4.4
    wget -O ${CHEETAH} ${CHEETAH_URL}
    ass_rst $? 0 "download cheetah failed"
    pr_ok "[download]<cheetah> ok"
    #下载mongodb 4.0.3
    wget -T 10 -O ${MONGODB} ${LOCAL_SRC_DIR}/${MONGODB}
    if [ $? -ne 0 ]; then
        wget -O ${MONGODB} "${MONGODB_URL}"
        ass_rst $? 0 "download mongodb failed"
    fi
    pr_ok "[download]<mongodb> ok"
	return 0
}

## Interface: compile_and_install_gcc7.2
function compile_install_gcc7()
{
    #编译安装gmp源码
    tar -xf gmp-6.1.0.tar.xz
    cd gmp-6.1.0
    ./configure --prefix=/usr/local/gmp
    make -j$CPU_NUM
    make install -j$CPU_NUM
    ass_rst $? 0 "install gmp failed"
    pr_ok "[install<gmp> ok"
    cd -
    #编译安装mpfr源码
    tar -xf mpfr-3.1.4.tar.xz
    cd mpfr-3.1.4
    ./configure --prefix=/usr/local/mpfr --with-gmp=/usr/local/gmp -build=none
    make -j$CPU_NUM
    make install -j$CPU_NUM
    ass_rst $? 0 "install mpfr failed"
    pr_ok "[install]<mpfr> ok"
    cd -
    #编译安装mpc源码
    tar -zxf mpc-1.0.3.tar.gz
    cd mpc-1.0.3
    ./configure --prefix=/usr/local/mpc --with-gmp-include=/usr/local/gmp/include/ --with-gmp-lib=/usr/local/gmp/lib/ --with-mpfr-include=/usr/local/mpfr/include/\
    --with-mpfr-lib=/usr/local/mpfr/lib/ --with-system-zlib --disable-multilib --enable-languages=c,c++ --enable-shared=no --enable-static=yes
    make -j$CPU_NUM
    make install -j$CPU_NUM
    ass_rst $? 0 "install mpc failed"
    pr_ok "[install]<mpc> ok"
    cd -
    #编译gcc7.2
    tar -xf gcc-7.2.0.tar.xz
    cd gcc-7.2.0
    ./configure --prefix=/usr/gcc7.2 --with-mpc=/usr/local/mpc --with-gmp-include=/usr/local/gmp/include/ --with-gmp-lib=/usr/local/gmp/lib/\
    --with-mpfr-include=/usr/local/mpfr/include/ --with-mpfr-lib=/usr/local/mpfr/lib/  --enable-threads=posix --disable-multilib --enable-languages=c,c++
    make -j$CPU_NUM
    make install -j$CPU_NUM
    cd -
    mv /usr/bin/gcc /usr/bin/gcc7.2
    ln -s /usr/gcc7.2/bin/gcc /usr/bin/gcc
    mv /usr/bin/g++ /usr/bin/g++7.2
    ln -s /usr/gcc7.2/bin/g++ /usr/bin/g++
    mv /usr/bin/c++ /usr/bin/c++7.2
    ln -s /usr/gcc7.2/bin/c++ /usr/bin/c++
    gcc_version=`gcc --version |head -n 1|awk '{print $3}'`
    if [ ${gcc_version} == '7.2.0' ] ; then
        pr_ok "[install]<gcc7.2> ok"
    else
        ass_rst 1 0 "install gcc7.2 failed"
    fi
    return 0
}

function compile_install_mongodb()
{
    #编译安装pip 19.0.2
    tar -zxf ${PIP}
    cd pip-19.0.2
    python setup.py install
    ass_rst $? 0 "install pip failed"
    pr_ok "[install]<pip> ok"
    cd -
    #编译安装setuptools-41.0.1
    unzip ${SETUPTOOLS}
    cd setuptools-41.0.1
    python setup.py install
    ass_rst $? 0 "install setuptools failed"
    pr_ok "[install]<setuptools> ok"
    cd -
    #编译安装Markdown-3.1.1
    pip install ${MARKDOWN}
    ass_rst $? 0 "install markdown failed"
    pr_ok "[install]<markdown> ok"
    #编译安装six1.12
    tar -zxf ${SIX}
    cd six-1.12.0
    python setup.py install
    ass_rst $? 0 "install six failed"
    pr_ok "[install]<six> ok"
    cd -
    #编译安装pyyaml5.1
    tar -zxf ${PYYAML}
    cd PyYAML-5.1
    python setup.py install
    ass_rst $? 0 "install pyyaml failed"
    pr_ok "[install]<pyyaml> ok"
    cd -
    #编译安装typing 3.6.6
    tar -zxf ${TYPING}
    cd typing-3.6.6
    python setup.py install
    ass_rst $? 0 "install typing failed"
    pr_ok "[install]<typing> ok"
    cd -
    #编译安装cheetah 2.4.4
    tar -zxf ${CHEETAH}
    cd Cheetah-2.4.4
    python setup.py install
    ass_rst $? 0 "install cheetah failed"
    pr_ok "[install]<cheethah> ok"
    cd -
    #编译安装mongodb 4.0.3
    unzip ${MONGODB}
    cd mongo-r4.0.3
    python buildscripts/scons.py mongod MONGO_VERSION=4.0.3 CCFLAGS="-march=armv8-a+crc" --disable-warnings-as-errors -j$CPU_NUM
    python buildscripts/scons.py --prefix=/usr/local/mongo install MONGO_VERSION=4.0.3 CCFLAGS="-march=armv8-a+crc" --disable-warnings-as-errors -j$CPU_NUM
    ass_rst $? 0 "install mongodb failed"
    pr_ok "[install]<mongodb> ok"
    if [ "$DISTRIBUTION"x == "CentOS"x ] ; then
        mv /usr/lib64/libstdc++.so.6 /usr/lib64/libstdc++.so.6.7.2
        cp -r ../gcc-7.2.0/prev-aarch64-unknown-linux-gnu/libstdc++-v3/src/.libs/libstdc++.so.6.0.24  /usr/lib64
        ln -s /usr/lib64/libstdc++.so.6.0.24  /usr/lib64/libstdc++.so.6
    fi 
    return 0
}

### Compile and Install ###
## Interface: compile_and_install
function compile_and_install()
{
    compile_install_gcc7
    compile_install_mongodb
}


### selftest ###
## Interface: software self test
## example: print version number, run any simple example
function selftest()
{
    /usr/local/mongo/bin/mongo --version
	ass_rst $? 0 "mongodb selftest failed"
    pr_ok "[selftest] ok"
    return 0
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

### uninstall ###
function uninstall()
{       
    rm -rf /usr/bin/gcc
    mv /usr/bin/gcc7.2 /usr/bin/gcc
    rm -rf /usr/bin/g++
    mv /usr/bin/g++7.2 /usr/bin/g++
    rm -rf /usr/bin/c++
    mv /usr/bin/c++7.2 /usr/bin/c++
    rm -rf /usr/local/gmp /usr/local/mpfr /usr/local/mpc /usr/gcc7.2 /usr/local/mongo
    rm -rf gmp-6.1.0* mpfr-3.1.4* mpc-1.0.3* gcc-7.2.0* pip-19.0.2* mongo-r4.0.3* setuptools-41.0.1* six-1.12.0* PyYAML-5.1* Cheetah-2.4.4* Markdown-3.1.1* typing-3.6.6* /mongodb
    if [ "$DISTRIBUTION"x == "CentOS"x ] ; then
        rm -rf /usr/lib64/libstdc++.so.6.0.24
        rm -rf /usr/lib64/libstdc++.so.6
        mv /usr/lib64/libstdc++.so.6.7.2 /usr/lib64/libstdc++.so.6
    fi
    pr_tip "[uninstall]<uninstall>"
    pr_ok "<uninstall> ok"
    return 0
}

### main code ###
function main()
{
    check_distribution
    ass_rst $? 0 "check_distribution failed!"

    if [ x"$1" == x"uninstall" ] ; then
        uninstall
        ass_rst $? 0 "uninstall failed!"
        exit 0
    fi
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
main $1
rst=$?

ass_rst $rst 0 "[FINAL] Software install,Fail!"

pr_ok " "
pr_ok "Software install OK!"

pr_tip "--------  software compile and install end  --------"

