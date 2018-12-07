#! /bin/bash

### Header info ###
## template: 	V01
## Author: 	XiaoJun x00467495
## name:	hive
## desc:	hive source code compile and install (maybe several hours)

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
hive=apache-hive-2.3.3-bin
testhome=/opt
LOCAL_SRC_DIR="192.168.1.107/src_collection"

#hadoop version
version='2.7.6'

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
	./hadoop.sh
	ass_rst $? 0 "hadoop install failed!"

	cd $testhome
	return $?
}

## Interface: download_src
function download_src()
{
if [ -d "$testhome/hive" ];then
	rm -rf $testhome/hive
	mkdir -p $testhome/hive
else
	mkdir -p $testhome/hive
fi
	pushd  $testhome/hive
	cd  $testhome/hive
	echo "download hive ,Please wait..."
	wget -T 10 -O ${hive}.tar.gz ${LOCAL_SRC_DIR}/${hive}.tar.gz
	if [ $? -ne 0 ] ; then
		wget -O ${hive}.tar.gz --no-check-certificate http://archive.apache.org/dist/hive/hive-2.3.3/${hive}.tar.gz
		ass_rst $? 0 "download failed"
	fi
	tar -xf ${hive}.tar.gz
	
	
    hivedir=`pwd`/${hive}
        echo '<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
	<property>
		<name>hive.metastore.warehouse.dir</name>
		<value>/user/hive/warehouse</value>
		<description>location of default database for the warehouse</description>
	</property>
	<property>
		<name>javax.jdo.option.ConnectionURL</name>
		<value>jdbc:derby:$testhome/hive/${hive}/metastore_db;create=true</value>
		<description>JDBC connect string for a JDBC metastore</description>
	</property>
</configuration>' > $testhome/hive/${hive}/conf/hive-site.xml
        sed -i "/HIVE_HOME/d" ~/.bashrc
        export HIVE_HOME=$hivedir &&
        echo "export HIVE_HOME=$hivedir" >> ~/.bashrc &&
        echo 'export PATH=$PATH:$HIVE_HOME/bin' >> ~/.bashrc
        source ~/.bashrc > /dev/null 2>&1
    popd
	
	return 0
}

## Interface: software self test
## example: print version number, run any simple example
function selftest()
{
hive -e "create table test1(a int,b string) row format delimited fields terminated by ',' stored as textfile;"
	if [ $? -eq 0 ];then
		pr_tip "[hive] Successed:hive_create_table successed."
	fi
hive -e "drop table test1;"

	hdfs dfs -rm -f -r /user/hive/warehouse
	hdfs dfs -rm -f -r /user/hive/tmp
	hdfs dfs -rm -f -r /user/hive/log

	cd $testhome/hadoop/hadoop-${version}/sbin
	./stop-all.sh
	return $?

}

## Interface: compile_and_install
function compile_and_install()
{
    hdfs dfs -mkdir -p /user/hive/warehouse
    hdfs dfs -mkdir -p /user/hive/tmp
    hdfs dfs  -mkdir -p /user/hive/log
    hdfs dfs -chmod -R 777 /user/hive/warehouse
    hdfs dfs -chmod -R 777 /user/hive/tmp
    hdfs dfs -chmod -R 777 /user/hive/log
	
	cd $testhome/hive/${hive}/bin
    schematool -initSchema -dbType derby
	ass_rst $? 0 "schematool -db successed"
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
