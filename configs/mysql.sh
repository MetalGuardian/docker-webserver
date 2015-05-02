#!/bin/bash

set -e

if [ ! -f /var/lib/mysql/ibdata1 ]; then

	mysql_install_db

	/usr/bin/mysqld_safe &
	sleep 10s

	echo "GRANT ALL ON *.* TO '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}' WITH GRANT OPTION; FLUSH PRIVILEGES" | mysql

	killall mysqld
	sleep 10s
fi

chown -R mysql:mysql /var/lib/mysql/

/usr/bin/mysqld_safe \
  --bind-address=0.0.0.0 \
  --skip-syslog \
  --log-warnings \
  --slow-query-log \
  --general-log
