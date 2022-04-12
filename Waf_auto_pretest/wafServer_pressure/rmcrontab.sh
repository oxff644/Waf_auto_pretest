#! /bin/sh
function remove_crontab()
{
	CMD="$1"
	is_restart=0
	awk '$0 != MATCHSTR' MATCHSTR="$CMD" /var/spool/cron/root > /var/spool/cron/root.bak
	if diff /var/spool/cron/root /var/spool/cron/root.bak 1>/dev/null 2>&1
	then
		is_restart=1
	fi
	mv -f /var/spool/cron/root.bak /var/spool/cron/root
	chmod 600 /var/spool/cron/root
	if [ $is_restart -eq 0 ]
	then
		echo "Remove crontab: $CMD"
		return 0
	else
		echo "crontab already removed: $CMD"
		return 1
	fi
}

line1="*/1 * * * * /bin/sh /usr/local/nginx/bin/package_access_log.sh 1>/dev/null 2>&1"
remove_crontab "$line1"
line2="*/1 * * * * /bin/sh /usr/local/nginx/bin/package_log.sh 1>/dev/null 2>&1"
remove_crontab "$line2"
line3="*/5 * * * * /usr/bin/python /usr/local/nginx/bin/check_conf_to_reload.py 1>/dev/null 2>&1"
remove_crontab "$line3"