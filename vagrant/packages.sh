#!/bin/sh

# set default answers to mysql server config questions
# and also enable unattended-upgrades
debconf-set-selections <<EOF
mysql-server-5.5 mysql-server/root_password password root
mysql-server-5.5 mysql-server/root_password_again password root
mysql-server-5.5 mysql-server-5.5/start_on_boot boolean true
unattended-upgrades unattended-upgrades/enable_auto_updates boolean true
EOF

# disable configuration prompts on install
export DEBIAN_FRONTEND="noninteractive"

echo "Installing and updating packages ..."
apt-get -qqy update
apt-get -qqy upgrade
apt-get -qqy install apache2 php5 php5-gd unattended-upgrades mysql-server mysql-client augeas-tools augeas-lenses libaugeas0 libaugeas-ruby php5-mysql git vim screen php-pear php-apc memcached build-essential

if [ ! -f /usr/bin/drush ] ; then 
	echo "Installing drush ..."
	pear channel-discover pear.drush.org
	pear install drush/drush
	# For some reason Drush needs to be run once with admin privileges
	drush 2>&1 > /dev/null
fi

echo "Installing PECL goodies ..."
if [ ! -f /etc/php5/conf.d/memcache.ini ]; then
  yes | pecl install memcache
  echo "extension=memcache.so" > /etc/php5/conf.d/memcache.ini
fi
if [ ! -f /etc/php5/conf.d/uploadprogress.ini ]; then
  pecl install uploadprogress
  echo "extension=uploadprogress.so" > /etc/php5/conf.d/uploadprogress.ini
fi
