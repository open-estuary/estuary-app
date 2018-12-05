#! /bin/bash

### Header info ###
## template: 	V01
## Author: 	XiaoJun x00467495
## name:	spark
## desc:	spark source code compile and install ( maybe several hours )

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
spark=/home/test/spark/spark-2.3.0-bin-hadoop2.7
localhost=172.31.31.116
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
scala -version
if [ $? -eq 0 ] ;then
echo -e "scala  already installed.\n"
else
	
   mkdir -p /usr/local/scala
   cd /usr/local/scala
   wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" https://downloads.typesafe.com/scala/2.11.8/scala-2.11.8.tgz
   tar -zxf scala-2.11.8.tgz
   echo "export SCALA_HOME="/usr/local/scala/scala-2.11.8"" >> /etc/profile
   echo "export PATH=$PATH:$SCALA_HOME/bin/" >> /etc/profile
   source /etc/profile  
fi
	cd /home/test
	./hadoop.sh
	return $?
}

## Interface: download_src
function download_src()
{
ls -l /home/test/spark
if [ $? -eq 0 ];then
   pr_tip "spark exists"
 rm -rf /home/test/spark
   mkdir -p /home/test/spark
else
   mkdir -p  /home/test/spark
fi
   cd /home/test/spark
   echo "download spark ,Please wait..."
   wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie"  https://archive.apache.org/dist/spark/spark-2.3.0/spark-2.3.0-bin-hadoop2.7.tgz
   tar -zxf spark-2.3.0-bin-hadoop2.7.tgz

	hdfs dfs -mkdir -p /tmp/spark/events
	cp $spark/conf/spark-env.sh.template $spark/conf/spark-env.sh
	echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk" >> $spark/conf/spark-env.sh
	echo "export SPARK_MASTER_IP=172.19.18.66" >> $spark/conf/spark-env.sh
	echo "export SPARK_WORKER_MEMORY=384G" >> $spark/conf/spark-env.sh
	echo "export SPARK_DIST_CLASSPATH=$(/home/test/hadoop/hadoop-2.7.6/bin/hadoop classpath)" >> $spark/conf/spark-env.sh
	echo "export SPARK_HISTORY_OPTS="-Dspark.history.ui.port=18080 -Dspark.history.fs.logDirectory=hdfs://$localhost:9000/tmp/spark/events"" >> $spark/conf/spark-env.sh
	cp $spark/conf/spark-defaults.conf.template $spark/conf/spark-defaults.conf
	echo "# spark history、log dir etc.
spark.eventLog.dir                hdfs://$localhost:9000/tmp/spark/events
spark.eventLog.compress           true
spark.eventLog.enabled            false
spark.serializer                   org.apache.spark.serializer.KryoSerializer
spark.history.fs.logDirectory        hdfs://$localhost:9000/tmp/spark/events
spark.yarn.historyServer.address     $localhost:18080
spark.history.ui.port               18080

# many errors, the root cause is executor is dead, execute bigdata of terasort may call.
spark.yarn.scheduler.heartbeat.interval-ms   120 
spark.executor.heartbeatInterval           120 
spark.network.timeout                   600 " >> $spark/conf/spark-defaults.conf
	
	grep HADOOP_HOME ~/.bashrc 
	if [ $? -eq 0 ];then
		sed -i "/SPARK_HOME/d" ~/.bashrc	
	fi
	export HADOOP_HOME=/home/test/spark/spark-2.3.0-bin-hadoop2.7
	echo "export HADOOP_HOME=/home/test/spark/spark-2.3.0-bin-hadoop2.7" >> ~/.bashrc
	echo 'export PATH=$PATH:$SPARK_HOME/bin' >> ~/.bashrc
	source ~/.bashrc > /dev/null 2>&1 


	#export SPARK_HOME=/home/test/spark/spark-2.3.0-bin-hadoop2.7
	#export PATH=$PATH:$SPARK_HOME/bin/:$SPARK_HOME/sbin
	#echo $PATH
	cd $spark/sbin
	./start-all.sh
	./start-history-server.sh
	return 0
}

## Interface: software self test
## example: print version number, run any simple example
function selftest()
{
	cd ${spark}/bin
	./run-example SparkPi
	cd /home/test/hadoop/hadoop-2.7.6/sbin
	./stop-all.sh
	
	return $?
}

## Interface: compile_and_install
function compile_and_install()
{
	
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
	
	#compile_and_install
	#ass_rst $? 0 "compile_and_install failed!"
	
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
