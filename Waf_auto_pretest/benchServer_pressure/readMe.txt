所有脚本的传参为：
# waf_version      host         concurrent_thread   repeat_time                测试数据           guid          mode
# waf版本        压测的域名     并发线程数   	         重复发送数据次数       data_version	   唯一标识     模式

e.g:
./prepare.sh 4.16.0-11 botsec.haplat.net 200 10 data_v1 111111111 pressure