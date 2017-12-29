#
# Regular cron jobs for the createap package
#
0 4	* * *	root	[ -x /usr/bin/createap_maintenance ] && /usr/bin/createap_maintenance
