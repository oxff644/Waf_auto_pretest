#!/bin/bash

# waf_version host        concurrent_thread  repeat_time        测试数据           guid         mode
# waf版本  	  压测的域名    并发数   			  重复发送数据次数	data_version	   唯一标识     模式

status=`curl http://115.54.16.68/testcdn.htm -H "Host:botsec.haplat.net" -i|sed -n 1p|awk '{print $2}'`
if [ $status = '200' ]
then
	echo 'connect successfully'
else
	dateStamp=$(date '+%Y-%m-%d:%H:%M:%S')
	echo "{\"error_type\":\"connect wafserver failed \", \"time\":\"$dateStamp\"}" >>/dev/stderr
	exit 1
fi

echo 'ready to send data!'
