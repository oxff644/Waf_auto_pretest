#!/bin/bash

# waf_version host        concurrent_thread  repeat_time        data_version    guid       mode
# waf版本  	  压测的域名    并发数   			  重复发送数据次数	测试数据	        唯一标识    模式


avg_nginxC=0
avg_nginxM=0
avg_sharkC=0
avg_sharkM=0
avg_squidC=0
avg_squidM=0
nginx_arrayC=()
nginx_arrayM=()
shark_arrayC=()
shark_arrayM=()
squid_arrayC=()
squid_arrayM=()

while true
do
	if test -e /usr/local/waf_test/tmp/${6}
	then
		break
	fi
	
	echo 'one time'
	total_nginxC=0
	total_nginxM=0
	PID_nginx_array=`ps -ef|grep nginx|grep worker|grep -v nobody|awk '{print $2}'`
	nginx_len=0
	for PID in $PID_nginx_array
	do
		if test -n "$PID"
		then
			CPU=`top -b -p $PID -n 1|grep nginx|awk '{print strtonum($(NF-4))}'`
			MEM=`top -b -p $PID -n 1|grep nginx|awk '{print strtonum($(NF-3))}'`
			total_nginxC=$(echo "scale=2; $total_nginxC+$CPU" | bc)
			total_nginxM=$(echo "scale=2; $total_nginxM+$MEM" | bc)
			nginx_len=$[$nginx_len+1]
			echo $CPU >> /usr/local/waf_test/analysis/${6}-${7}/nginx/nginx-$PID.CPU
			echo $MEM >> /usr/local/waf_test/analysis/${6}-${7}/nginx/nginx-$PID.MEM
		fi
	done
	echo "nginx_len:$nginx_len"
	nginx_arrayC+=($(echo "scale=2; $total_nginxC/$nginx_len" | bc))
	nginx_arrayM+=($(echo "scale=2; $total_nginxM/$nginx_len" | bc))

	total_sharkC=0
	total_sharkM=0
	shark_len=0
	PID_shark_array=`ps -ef|grep shark|grep worker|awk '{print $2}'`
	for PID in $PID_shark_array
	do
		if test -n "$PID"
		then
			CPU=`top -b -p $PID -n 1|grep shark|awk '{print strtonum($(NF-4))}'`
			MEM=`top -b -p $PID -n 1|grep shark|awk '{print strtonum($(NF-3))}'`
			if test -z "$CPU" -o -z "$MEM"
			then
				continue
			fi
			total_sharkC=$(echo "scale=2; $total_sharkC+$CPU" | bc)
			total_sharkM=$(echo "scale=2; $total_sharkM+$MEM" | bc)
			shark_len=$[$shark_len+1]
			echo $CPU >> /usr/local/waf_test/analysis/${6}-${7}/shark/shark-$PID.CPU
			echo $MEM >> /usr/local/waf_test/analysis/${6}-${7}/shark/shark-$PID.MEM
		fi
	done
	echo "shark_len:$shark_len"
	shark_arrayC+=($(echo "scale=2; $total_sharkC/$shark_len" | bc))
	shark_arrayM+=($(echo "scale=2; $total_sharkM/$shark_len" | bc))


	total_squidC=0
	total_squidM=0
	squid_len=0
	PID_squid_array=`ps -ef|grep '(squid)'|grep -v root|awk '{print $2}'`
	for PID in $PID_squid_array
	do
		if test -n "$PID"
		then
			CPU=`top -b -p $PID -n 1|grep squid|awk '{print strtonum($(NF-4))}'`
			MEM=`top -b -p $PID -n 1|grep squid|awk '{print strtonum($(NF-3))}'`
			if test -z "$CPU" -o -z "$MEM"
			then
				continue
			fi
			total_squidC=$(echo "scale=2; $total_squidC+$CPU" | bc)
			total_squidM=$(echo "scale=2; $total_squidM+$MEM" | bc)
			squid_len=$[$squid_len+1]
			echo $CPU >> /usr/local/waf_test/analysis/${6}-${7}/squid/squid-$PID.CPU
			echo $MEM >> /usr/local/waf_test/analysis/${6}-${7}/squid/squid-$PID.MEM
		fi
	done
	echo "squid_len:$squid_len"
	squid_arrayC+=($(echo "scale=2; $total_squidC/$squid_len" | bc))
	squid_arrayM+=($(echo "scale=2; $total_squidM/$squid_len" | bc))

	sleep 5
done

len=${#nginx_arrayC[*]}
for((i=1;i<$[$len-3];i++))
do
	avg_nginxC=$(echo "scale=2; $avg_nginxC+${nginx_arrayC[i]}" | bc)
	avg_nginxM=$(echo "scale=2; $avg_nginxM+${nginx_arrayM[i]}" | bc)
	avg_sharkC=$(echo "scale=2; $avg_sharkC+${shark_arrayC[i]}" | bc)
	avg_sharkM=$(echo "scale=2; $avg_sharkM+${shark_arrayM[i]}" | bc)
	avg_squidC=$(echo "scale=2; $avg_squidC+${squid_arrayC[i]}" | bc)
	avg_squidM=$(echo "scale=2; $avg_squidM+${squid_arrayM[i]}" | bc)
done

avg_nginxC=$(echo "scale=2; $avg_nginxC/($len-4)" | bc)
avg_nginxM=$(echo "scale=2; $avg_nginxM/($len-4)" | bc)
avg_sharkC=$(echo "scale=2; $avg_sharkC/($len-4)" | bc)
avg_sharkM=$(echo "scale=2; $avg_sharkM/($len-4)" | bc)
avg_squidC=$(echo "scale=2; $avg_squidC/($len-4)" | bc)
avg_squidM=$(echo "scale=2; $avg_squidM/($len-4)" | bc)

echo "nginx: ${nginx_arrayC[*]}" >> /usr/local/waf_test/analysis/${6}-${7}/avg
echo "shark: ${shark_arrayC[*]}" >> /usr/local/waf_test/analysis/${6}-${7}/avg
echo "squid: ${squid_arrayC[*]}" >> /usr/local/waf_test/analysis/${6}-${7}/avg

echo "avg_nginxC=$avg_nginxC" >> /usr/local/waf_test/analysis/${6}-${7}/report.txt
echo "avg_nginxM=$avg_nginxM" >> /usr/local/waf_test/analysis/${6}-${7}/report.txt
echo "avg_sharkC=$avg_sharkC" >> /usr/local/waf_test/analysis/${6}-${7}/report.txt
echo "avg_sharkM=$avg_sharkM" >> /usr/local/waf_test/analysis/${6}-${7}/report.txt
echo "avg_squidC=$avg_squidC" >> /usr/local/waf_test/analysis/${6}-${7}/report.txt
echo "avg_squidM=$avg_squidM" >> /usr/local/waf_test/analysis/${6}-${7}/report.txt
