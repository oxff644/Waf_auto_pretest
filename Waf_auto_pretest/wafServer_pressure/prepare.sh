#!/bin/bash

# waf_version host        concurrent_thread  repeat_time        data_version    guid       mode
# waf版本  	  压测的域名    并发数   			  重复发送数据次数	测试数据	        唯一标识    模式


# 检测当前waf版本是否对应，安装相应的waf版本
current_version=`/usr/local/nginx/sbin/nginx -v 2>&1 |grep 'wswaf'|awk -F"[ /]" '{print $4}'|awk -F ".el6|.standalone" '{print $1}'`
compare=$(echo $current_version ${1} | awk '$1>$2 {print 1} $1==$2 {print 0} $1<$2 {print 2}')
if test -z $current_version
then
	# 当前机器没有waf版本，安装对应的rpm包
	rpm -ivh /usr/local/waf_test/sbin/wswaf-${1}.el6.x86_64.rpm
elif [ $compare = 1 ]
then
	# 当前机器waf版本高于要安装的版本,需要回退
	rpm -Uvh /usr/local/waf_test/sbin/wswaf-${1}.el6.x86_64.rpm --oldpackage
elif [ $compare = 2 ]
then
	# 当前机器waf版本低于要安装的版本
	rpm -Uvh /usr/local/waf_test/sbin/wswaf-${1}.el6.x86_64.rpm
else
	echo "correct waf version!"
fi
# 再次检测版本
current_version=`/usr/local/nginx/sbin/nginx -v 2>&1 |grep 'wswaf'|awk -F"[ /]" '{print $4}'|awk -F ".el6|.standalone" '{print $1}'`
if [ $current_version != ${1} ]
then
	dateStamp=$(date '+%Y-%m-%d:%H:%M:%S')
	echo "{\"error_type\":\"wswaf-${1} install failed \", \"time\":\"$dateStamp\"}" >>/dev/stderr
	exit 1
fi

# 更改squid配置文件
sed -i '/domain_replace_dst_ip/c\domain_replace_dst_ip 117.23.51.196' /usr/local/squid/etc/channel/ws_${2}.conf
service squid reload
sleep 60

# 更改shark配置文件
# s是替换，-i表示在原文件上操作，^表示句首，&表示在匹配到的字符前加入&前的字符#，g表示global全部替换，不加g表示只替换每行第一个
sed  -i 's/^[ ]*server 121.46.247.124:9101 max_fails=0;/#&/g' /usr/local/shark/etc/shark.conf
service shark reload
sleep 60

# 关闭打包程序
sh /usr/local/waf_test/sbin/rmcrontab.sh

# 如果tmp下原有signal文件，则删除
if test -e /usr/local/waf_test/tmp/${6}
then
	rm -f /usr/local/waf_test/tmp/${6}
fi

# 清空access.log
echo -n > /usr/local/nginx/logs/access/access.log

echo "ready to analyze data!"
sleep 60
