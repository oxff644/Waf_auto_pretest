#!/bin/bash

# waf_version host        concurrent_thread  repeat_time        data_version     guid       mode
# waf版本  	  压测的域名    并发数   			  重复发送数据次数	测试数据	         唯一标识    模式
 

mkdir /usr/local/waf_test/analysis/${6}-${7}
mkdir /usr/local/waf_test/analysis/${6}-${7}/nginx
mkdir /usr/local/waf_test/analysis/${6}-${7}/shark
mkdir /usr/local/waf_test/analysis/${6}-${7}/squid

sh /usr/local/waf_test/sbin/gainCpuMem.sh ${1} ${2} ${3} ${4} ${5} ${6} ${7}
