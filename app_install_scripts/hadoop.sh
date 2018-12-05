#! /bin/bash

### Header info ###
## template: 	V01
## Author: 	XiaoJun x00467495
## name:	hadoop
## desc:	hadoop hive source code compile and install (maybe several hours)

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
case $DISTRIBUTION in
      "CentOS")
        DEPENDENCE="java-1.8.0-openjdk java-1.8.0-openjdk-devel wget"
		pr_tip "[depend] $DEPENDENCE"
        yum --setopt=skip_missing_names_on_install=False install -y ${DEPENDENCE}
        ;;
    "Debian")
        DEPENDENCE="wget openjdk-8-jdk openjdk-8-jre"
        pr_tip "[depend] $DEPENDENCE"
		apt-get install -y $DEPENDENCE	
        ;;
		
 esac
 ass_rst $? 0 "install dependence failed"
 
	
    if [ ! -f "/usr/lib/jvm/java-1.8.0-openjdk-arm64" ];then
		echo ""
	else
		mv /usr/lib/jvm/java-1.8.0-openjdk-arm64  /usr/lib/jvm/java-1.8.0-openjdk
	fi
	sed -i "/JAVA_HOME/d" ~/.bashrc
    echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk" >> ~/.bashrc
    echo 'export PATH=$PATH:$JAVA_HOME/bin' >> ~/.bashrc
	
    jps > /dev/null
    
	return $?
}

## Interface: download_src
function download_src()
{
	if [ -d "/home/test/hadoop" ];then
		rm -rf /home/test/hadoop
		mkdir -p /home/test/hadoop
	else
		mkdir -p /home/test/hadoop
	fi
	cd /home/test/hadoop
	echo "download hadoop,Please wait... "
	wget --no-check-certificate  http://mirror.bit.edu.cn/apache/hadoop/common/hadoop-${version}/hadoop-${version}.tar.gz
	ass_rst $? 0 "download failed"
	tar -xf hadoop-${version}.tar.gz
	
	pushd hadoop-${version}
	
    sed -i "s/export JAVA_HOME=.*/export JAVA_HOME=\/usr\/lib\/jvm\/java-1.8.0-openjdk/g" etc/hadoop/hadoop-env.sh
	
	grep HADOOP_HOME ~/.bashrc 
	if [ $? -eq 0 ];then
		sed -i "/HADOOP_HOME/d" ~/.bashrc	
	fi
	export HADOOP_HOME=`pwd`
	echo "export HADOOP_HOME=`pwd`" >> ~/.bashrc
	echo 'export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin' >> ~/.bashrc
	source ~/.bashrc > /dev/null 2>&1 
    
    popd
	
	pr_tip "[download] hadoop-${version}"
	return 0
}

## Interface: software self test
## example: print version number, run any simple example
function selftest()
{
cd $HADOOP_HOME
	rm -rf input output
	mkdir input
  	cp etc/hadoop/*.xml input
  	bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-${version}.jar grep input output 'dfs[a-z.]+' > /dev/null 2>&1
  	if [ -f output/_SUCCESS ];then
                pr_tip  0 "hadoop_standalone_test"
	else
                pr_tip  1 "hadoop_standalone_test"
	fi
cd $HADOOP_HOME/bin
./hadoop version	
	return $?
}

## Interface: compile_and_install
function compile_and_install()
{
	if [ -d ~/.ssh ];then
        rm -rf ~/.ssh
    fi
    
    ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    chmod 0600 ~/.ssh/authorized_keys
	echo  "StrictHostKeyChecking=no" >> ~/.ssh/config
	
	 pushd $HADOOP_HOME
    cp etc/hadoop/core-site.xml{,.bak}
    cat <<EOF >etc/hadoop/core-site.xml
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/tmp/hadoop-root</value>
    </property>
</configuration>

EOF


    cp etc/hadoop/hdfs-site.xml{,.bak}
    cat <<EOF > etc/hadoop/hdfs-site.xml
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
    <property>
	<name>dfs.data.dir</name>
	<value>hadoop_dir/data</value>
    </property>
</configuration>
EOF
   
cp  etc/hadoop/mapred-site.xml.template etc/hadoop/mapred-site.xml
cat > etc/hadoop/mapred-site.xml <<EOF
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
</configuration>
EOF
    
    cat > etc/hadoop/yarn-site.xml <<EOF
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
</configuration>
EOF
	#rm -rf /tmp/hadoop-root
	$HADOOP_HOME/bin/hdfs namenode -format
	$HADOOP_HOME/sbin/start-dfs.sh
	$HADOOP_HOME/sbin/start-yarn.sh
	$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver
    popd 
	
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
