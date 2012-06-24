#!/bin/bash
# ar1hur 2012

######## configuration ###############
DB_USER="root"
DB_PASS="root"
DB_NAME_LIVE="db_live"
DB_NAME_TEST="db_test"

# magento base urls with "/" at the end(!)
BASEURL_TEST_UNSECURE="http://test.domain.de/" 
BASEURL_TEST_SECURE="https://test.domain.de/"
######################################

dump="live_dump_$DB_NAME_LIVE.sql"
mysqldump -u$DB_USER -p$DB_PASS $DB_NAME_LIVE > $dump

if [ -a $dump ]; then
	result=`mysql -u"$DB_USER" -p"$DB_PASS" -e "SHOW DATABASES;" | grep "$DB_NAME_TEST"`
	if [ "$DB_NAME_TEST" == "$result" ]; then
		echo "info: test database exists! dropping..."
		mysql -uroot -proot -e "DROP DATABASE $DB_NAME_TEST;"
	else
		echo "info: test database doesn't exist..."
	fi
	echo "info: creating database $DB_NAME_TEST..."
	mysql -u"$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE $DB_NAME_TEST;"

	echo "info: updating test db..."
	mysql -u"$DB_USER" -p"$DB_PASS" -D$DB_NAME_TEST < $dump

	# magento specific
	echo "info: updating magento config -> domain..."
        mysql -u"$DB_USER" -p"$DB_PASS" -D$DB_NAME_TEST -e "UPDATE core_config_data SET value='$BASEURL_TEST_UNSECURE' WHERE path='web/unsecure/base_url';"
	mysql -u"$DB_USER" -p"$DB_PASS" -D$DB_NAME_TEST -e "UPDATE core_config_data SET value='$BASEURL_TEST_SECURE' WHERE path='web/secure/base_url';"
	echo "done."
else
	echo "error: could not create dump of $DB_NAME_LIVE! aborting..."
fi
