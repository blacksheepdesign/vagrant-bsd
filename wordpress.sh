#!/usr/bin/env bash

mkdir -p /var/www/html
cd /var/www/html

if [ ! -d "/var/www/html/wp-admin" ]; then
    # Control will enter here if $DIRECTORY doesn't exist.
    wp core download
fi

DB_PREFIX='none'

if [ -f "/var/www/html/wp-config.php" ]; then
    # Control will enter here if $DIRECTORY doesn't exist.
    echo "wp-config.php already exists, creating backup..."
	DB_PREFIX=$( cat /var/www/html/wp-config.php | grep "\$table_prefix" | cut -d \' -f 2 )
    mv wp-config.php wp-config.php.backup
fi

# create random password
PASSWDDB="$(openssl rand -base64 12)"

ROOTPASS=`cat ~/mysql_root.txt`

mysql -uroot -p$ROOTPASS -e "CREATE DATABASE wordpress;"
mysql -uroot -p$ROOTPASS -e "CREATE USER wp_user@localhost IDENTIFIED BY '${PASSWDDB}';"
mysql -uroot -p$ROOTPASS -e "GRANT ALL PRIVILEGES ON wordpress.* TO wp_user@localhost;"
mysql -uroot -p$ROOTPASS -e "FLUSH PRIVILEGES;"

if [ -f /vagrant/dev-database.sql ]; then
    mysql wordpress -u root -p$ROOTPASS < /vagrant/dev-database.sql
fi

if [[ $DB_PREFIX != 'none' ]]; then
	wp core config --dbname=wordpress --dbuser=wp_user --dbpass=$PASSWDDB --dbprefix=$DB_PREFIX
else
	wp core config --dbname=wordpress --dbuser=wp_user --dbpass=$PASSWDDB
fi