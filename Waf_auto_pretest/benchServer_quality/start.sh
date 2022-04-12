#!/bin/bash

# test_type baseline_version   waf_version          data_version  operation                       guid
# 压测类型  基线版本对应waf版本  当前需要测试的waf版本  压测数据版本   0：测试基线版本，1：测试waf版本   每次测试的唯一标识 

python /usr/local/waf_test/sbin/play_back.py 121.46.247.123

sh /usr/local/waf_test/sbin/finish.sh
