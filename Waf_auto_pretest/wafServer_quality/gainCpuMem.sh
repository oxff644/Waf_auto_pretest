#!/bin/bash

# test_type baseline_version   waf_version          analysis_version  operation                 guid
# 压测类型  基线版本对应waf版本  当前需要测试的waf版本  压测数据版本   0：测试基线版本，1：测试waf版本  本次测试的唯一标识

totalC=0
totalM=0
PID_array=`ps -ef|grep nginx|grep worker|grep -v nobody|awk '{print $2}'`
for PID in $PID_array
do
	if test -n $PID
	then
		CPU=`top -b -p $PID -n 1|grep nginx|awk '{print strtonum($(NF-4))}'`
		MEM=`top -b -p $PID -n 1|grep nginx|awk '{print strtonum($(NF-3))}'`
		totalC=$(echo "scale=2; $totalC+$CPU" | bc)
		totalM=$(echo "scale=2; $totalM+$MEM" | bc)
		if [ ${5} = 0 ]
		then
			echo $CPU >> /usr/local/waf_test/baseline/${2}-${4}-${1}/cpu/$PID.CPU
			echo $MEM >> /usr/local/waf_test/baseline/${2}-${4}-${1}/mem/$PID.MEM
		else
			echo $CPU >> /usr/local/waf_test/analysis/${6}-${1}/cpu/test/$PID.CPU
			echo $MEM >> /usr/local/waf_test/analysis/${6}-${1}/mem/test/$PID.MEM
		fi
	fi
done

# 存储总的MEM和CPU
if [ ${5} = 0 ]
then
	echo $totalC >> /usr/local/waf_test/baseline/${2}-${4}-${1}/cpu/totalC
	echo $totalM >> /usr/local/waf_test/baseline/${2}-${4}-${1}/mem/totalM
else
	echo $totalC >> /usr/local/waf_test/analysis/${6}-${1}/cpu/test/totalC
	echo $totalM >> /usr/local/waf_test/analysis/${6}-${1}/mem/test/totalM
fi
