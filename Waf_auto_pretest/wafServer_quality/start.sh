#!/bin/bash

# test_type baseline_version   waf_version          data_version  operation                       guid
# 压测类型  基线版本对应waf版本  当前需要测试的waf版本  压测数据版本   0：测试基线版本，1：测试waf版本   每次测试的唯一标识 

# 运行数据分析代码

sh /usr/local/waf_test/sbin/opt_mode1.sh ${1} ${2} ${3} ${4} ${5} ${6}
