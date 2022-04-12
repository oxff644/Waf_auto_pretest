#!/bin/bash

# test_type baseline_version   waf_version          data_version  operation                      guid
# 压测类型  基线版本对应waf版本  当前需要测试的waf版本  压测数据版本   0：测试基线版本，1：测试waf版本   本次测试的唯一标识
 
# 创建不存在的新测试版本目录

if [ ${5} = 1 ]
then
	mkdir /usr/local/waf_test/analysis/${6}-${1}
	mkdir /usr/local/waf_test/analysis/${6}-${1}/mem
	mkdir /usr/local/waf_test/analysis/${6}-${1}/mem/baseline
	mkdir /usr/local/waf_test/analysis/${6}-${1}/mem/test
	mkdir /usr/local/waf_test/tmp/${6}-${1}
	mkdir /usr/local/waf_test/tmp/${6}-${1}/bak  # 存放测试的access.log
	mkdir /usr/local/waf_test/analysis/${6}-${1}/cpu
	mkdir /usr/local/waf_test/analysis/${6}-${1}/cpu/baseline
	mkdir /usr/local/waf_test/analysis/${6}-${1}/cpu/test
	mkdir /usr/local/waf_test/tmp/${6}-${1}/error_status  # 存放domain.log
	cp -rf /usr/local/waf_test/baseline/${2}-${4}-${1}/cpu/* /usr/local/waf_test/analysis/${6}-${1}/cpu/baseline
	cp -rf /usr/local/waf_test/baseline/${2}-${4}-${1}/mem/* /usr/local/waf_test/analysis/${6}-${1}/mem/baseline
	mkdir /usr/local/waf_test/analysis/${6}-${1}/domain
	mkdir /usr/local/waf_test/analysis/${6}-${1}/domain/baseline
	mkdir /usr/local/waf_test/analysis/${6}-${1}/domain/test
else
	if [ -d "/usr/local/waf_test/baseline/${2}-${4}-${1}" ]
	then
		rm -rf /usr/local/waf_test/baseline/${2}-${4}-${1}
		rm -rf /usr/local/waf_test/tmp/${2}-${4}-${1}
		echo '基线版本已清空'
	fi
	mkdir /usr/local/waf_test/baseline/${2}-${4}-${1}
	mkdir /usr/local/waf_test/baseline/${2}-${4}-${1}/mem
	mkdir /usr/local/waf_test/baseline/${2}-${4}-${1}/cpu
	mkdir /usr/local/waf_test/tmp/${2}-${4}-${1}
	mkdir /usr/local/waf_test/tmp/${2}-${4}-${1}/bak
	mkdir /usr/local/waf_test/tmp/${2}-${4}-${1}/error_status
fi

# 每隔一分钟取日志的循环在这个Python脚本中执行,直接得到全部域名的状态码统计
python2.7 /usr/local/waf_test/sbin/logHandle_opt.py ${1} ${2} ${3} ${4} ${5} ${6}

