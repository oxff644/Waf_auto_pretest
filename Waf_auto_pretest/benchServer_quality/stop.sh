#!/bin/bash

# test_type baseline_version   waf_version          data_version  operation                       guid
# 压测类型  基线版本对应waf版本  当前需要测试的waf版本  压测数据版本   0：测试基线版本，1：测试waf版本   每次测试的唯一标识 

kill `ps -ef|grep ${6}|grep -v grep|awk '{print $2}'`
echo "测试已中止"
