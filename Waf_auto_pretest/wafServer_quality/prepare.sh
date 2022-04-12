#!/bin/bash

# test_type baseline_version   waf_version          data_version  operation                       guid
# 压测类型  基线版本对应waf版本  当前需要测试的waf版本  压测数据版本   0：测试基线版本，1：测试waf版本   每次测试的唯一标识 

:<<EOF
# 从test server下载包
server_host=`sed -n 1p /usr/local/waf_test/conf/server.config |cut -d " " -f2`
server_port=`sed -n 2p /usr/local/waf_test/conf/server.config |cut -d " " -f2`
server_ip=`sed -n 3p /usr/local/waf_test/conf/server.config |cut -d " " -f2`
hdr=`sed -n 4p /usr/local/waf_test/conf/server.config |cut -d " " -f2`
hdr_value=`sed -n 4p /usr/local/waf_test/conf/server.config |cut -d " " -f3`
url="http://${server_ip}:${server_port}/download/waf/${6}.tgz"
echo $url
wget -P /usr/local/waf_test/sbin/ $url -d --header=$server_host --header="$hdr:$hdr_value"
tar -zxf /usr/local/waf_test/sbin/${6}.tgz # rpm在package下，脚本在/package/scripts下
EOF

# 检测当前waf版本是否对应，安装相应的waf版本
current_version=`/usr/local/nginx/sbin/nginx -v 2>&1 |grep 'wswaf'|awk -F"[ /]" '{print $4}'|awk -F ".el6|.standalone" '{print $1}'`
compare=$(echo $current_version ${3} | awk '$1>$2 {print 1} $1==$2 {print 0} $1<$2 {print 2}')
if test -z $current_version
then
	# 当前机器没有waf版本，安装对应的rpm包
	rpm -ivh /usr/local/waf_test/sbin/wswaf-${3}.el6.x86_64.rpm
elif [ $compare = 1 ]
then
	# 当前机器waf版本高于要安装的版本,需要回退
	rpm -Uvh /usr/local/waf_test/sbin/wswaf-${3}.el6.x86_64.rpm --oldpackage
elif [ $compare = 2 ]
then
	# 当前机器waf版本低于要安装的版本
	rpm -Uvh /usr/local/waf_test/sbin/wswaf-${3}.el6.x86_64.rpm
else
	echo "correct waf version!"
fi
# 再次检测版本
current_version=`/usr/local/nginx/sbin/nginx -v 2>&1 |grep 'wswaf'|awk -F"[ /]" '{print $4}'|awk -F ".el6|.standalone" '{print $1}'`
if [ $current_version != ${3} ]
then
	dateStamp=$(date '+%Y-%m-%d:%H:%M:%S')
	echo "{\"error_type\":\"wswaf-${3} install failed \", \"time\":\"$dateStamp\"}" >>/dev/stderr
	exit 1
fi

# 检查conf文件，替换成标准配置
sed -i '/server   127.0.0.1/c\        server   127.0.0.1:7101 max_fails=0  fail_timeout=30s;' /usr/local/nginx/conf/nginx.conf

# reload
service nginx reload
sleep 60

# 关闭打包程序
sh /usr/local/waf_test/sbin/rmcrontab.sh

# 如果tmp下存在未删掉的signal文件，则删去
if test -e /usr/local/waf_test/tmp/signal
then
	rm -f /usr/local/waf_test/tmp/signal
	echo "signal已删除"
fi

# 清空access.log
echo -n > /usr/local/nginx/logs/access/access.log

echo "ready to analyze data!"
