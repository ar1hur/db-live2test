#!/bin/bash
# ar1hur 2012

######## configuration ###############
DB_USER="root"
DB_PASS="root"
DB_NAME_LIVE="db_live"
DB_NAME_TEST="db_test"
######################################

dump="live_dump_$DB_NAME_LIVE.sql"
mysqldump -u$DB_USER -p$DB_PASS $DB_NAME_LIVE > $dump

if [ -a $dump ]; then
	result=`mysql -u"$DB_USER" -p"$DB_PASS" -e "SHOW DATABASES;" | grep "$DB_NAME_TEST"`
	if [ "$DB_NAME_TEST" == "$result" ]; then
		echo "info: test database exists! dropping..."
		mysql -u"$DB_USER" -p"$DB_PASS" -e "DROP DATABASE $DB_NAME_TEST;"
	else
		echo "info: test database doesn't exist..."
	fi
	echo "info: creating database $DB_NAME_TEST..."
	mysql -u"$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE $DB_NAME_TEST;"

	echo "info: updating test db..."
	mysql -u"$DB_USER" -p"$DB_PASS" -D$DB_NAME_TEST < $dump
	echo "done."
else
	echo "error: could not create dump of $DB_NAME_LIVE! aborting..."
fi
