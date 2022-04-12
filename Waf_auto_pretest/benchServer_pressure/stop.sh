#!/bin/bash

# waf_version host        concurrent_thread  repeat_time        测试数据           guid         mode
# waf版本  	  压测的域名    并发数   			  重复发送数据次数	data_version	   唯一标识      模式


kill `ps -ef|grep ${6}|grep -v grep|awk '{print $2}'`
echo '测试已中止'
