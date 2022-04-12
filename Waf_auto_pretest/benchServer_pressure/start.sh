#!/bin/bash

# waf_version host        concurrent_thread  repeat_time        测试数据           guid       mode
# waf版本  	  压测的域名    并发数   			  重复发送数据次数	data_version	   唯一标识   模式

mkdir /usr/local/waf_test/analysis/${6}-${7}

python /usr/local/waf_test/sbin/play_back.py ${1} ${2} ${3} ${4} ${5} ${6} ${7}

sh /usr/local/waf_test/sbin/finish.sh ${1} ${2} ${3} ${4} ${5} ${6} ${7}
