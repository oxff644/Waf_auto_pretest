#!/bin/bash

# waf_version host        concurrent_thread  repeat_time        data_version    guid       mode
# waf版本  	  压测的域名    并发数   			  重复发送数据次数	测试数据	        唯一标识    模式


touch /usr/local/waf_test/tmp/${6}
sleep 10

echo -n > /usr/local/waf_test/tmp/info.json
tar zcPf /usr/local/waf_test/upload.tar /usr/local/waf_test/analysis/${6}-${7}
echo "{\"result\":\"success\", \"file_path\":\"/usr/local/waf_test/upload.tar\"}" > /usr/local/waf_test/tmp/info.json

curl -X POST http://127.0.0.1:60001/finished_bench -H "content-type:application/json" -T /usr/local/waf_test/tmp/info.json
echo "finished"
