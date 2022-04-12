#!/bin/bash

# waf_version host        concurrent_thread  repeat_time        测试数据           guid       mode
# waf版本  	  压测的域名    并发数   			  重复发送数据次数	data_version	   唯一标识   模式


curl -X POST http://localhost:60002/finished_bench -H "content-type:application/json" -d "{\"result\": \"success\"}"
echo "finished"
