#!/bin/bash

# test_type baseline_version   waf_version          data_version  operation                       guid
# 压测类型  基线版本对应waf版本  当前需要测试的waf版本  压测数据版本   0：测试基线版本，1：测试waf版本   每次测试的唯一标识 

status=`curl http://121.46.247.123/testcdn.htm -H "Host:lvs.lxdns.net" -i|sed -n 1p|awk '{print $2}'`
if [ $status = '200' ]
then
	echo 'connect successfully'
else
	dateStamp=$(date '+%Y-%m-%d:%H:%M:%S')
	echo "{\"error_type\":\"connect wafserver failed \", \"time\":\"$dateStamp\"}" >>/dev/stderr
	exit 1
fi

echo 'ready to send data!'
