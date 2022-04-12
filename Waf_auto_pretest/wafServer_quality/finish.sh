#!/bin/bash

# test_type baseline_version   waf_version          data_version  operation                      guid
# 压测类型  基线版本对应waf版本  当前需要测试的waf版本  压测数据版本   0：测试基线版本，1：测试waf版本   本次测试的唯一标识

# 在tmp目录下创建signal文件，作为logHandle.py结束的信号
touch /usr/local/waf_test/tmp/signal
sleep 100

echo -n > /usr/local/waf_test/tmp/info.json
if [ ${5} = 0 ]
then
	echo "{\"result\":\"success\"}" > /usr/local/waf_test/tmp/info.json
else
	# 基准版和测试版进行对比
	if [ -d "/usr/local/waf_test/baseline/${2}-${4}-${1}" ]
	then
		python2.7 /usr/local/waf_test/sbin/dataException_opt.py ${1} ${2} ${3} ${4} ${5} ${6} 
	else
		dateStamp=$(date '+%Y-%m-%d:%H:%M:%S')
		echo "{\"error_type\":\"wswaf-${2} doesn't exist \", \"time\":\"$dateStamp\"}" >> /dev/stderr
	fi
	tar zcPf /usr/local/waf_test/analysis/${6}-${1}/upload.tar /usr/local/waf_test/analysis/${6}-${1}/format_error.log  /usr/local/waf_test/analysis/${6}-${1}/report.txt /usr/local/waf_test/analysis/${6}-${1}/cpu /usr/local/waf_test/analysis/${6}-${1}/mem /usr/local/waf_test/analysis/${6}-${1}/domain
	echo "{\"result\":\"success\", \"file_path\":\"/usr/local/waf_test/analysis/${6}-${1}/upload.tar\"}" > /usr/local/waf_test/tmp/info.json
fi


curl -X POST http://127.0.0.1:60001/finished_bench -H "content-type:application/json" -T /usr/local/waf_test/tmp/info.json
echo "finished"
