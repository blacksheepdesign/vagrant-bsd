#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

MYSQL_ROOT_PASSWORD="$(openssl rand -base64 12)"

echo $MYSQL_ROOT_PASSWORD >> /home/vagrant/mysql_root.txt
printf "[mysqldump]\nuser=root\npassword=$MYSQL_ROOT_PASSWORD\n" > /home/vagrant/.my.cnf
printf "[mysqldump]\nuser=root\npassword=$MYSQL_ROOT_PASSWORD\n" > /root/.my.cnf
chmod 600 /home/vagrant/.my.cnf
chmod 600 /root/.my.cnf

chown vagrant:vagrant /home/vagrant/mysql_root.txt
chown vagrant:vagrant /home/vagrant/.my.cnf

apt-get update -qq > /dev/null
apt-get install apache2 -qq > /dev/null

echo mysql-server-5.5 mysql-server/root_password password $MYSQL_ROOT_PASSWORD | debconf-set-selections
echo mysql-server-5.5 mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD | debconf-set-selections

apt-get install -y mysql-server php5-mysql -qq > /dev/null

mysql_install_db

aptitude -y install expect

SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"$MYSQL_ROOT_PASSWORD\r\"
expect \"Change the root password?\"
send \"n\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")

echo "$SECURE_MYSQL"

aptitude -y purge expect

apt-get -y install php5 libapache2-mod-php5 php5-mcrypt php5-gd libssh2-php -qq > /dev/null

if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant /var/www
fi

service apache2 restart

curl -O -s https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar > /dev/null
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
