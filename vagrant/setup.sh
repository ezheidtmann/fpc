#!/bin/bash

# HOWTO add another multisite:
# 1) Add "CREATE DATABASE ..."
# 2) Add sitename to "for site in ..."

# mysqld listen to world (to allow port forwarding to work)
augtool <<EOF
set /files/etc/mysql/my.cnf/*/bind-address 0.0.0.0
set /files/etc/php5/apache2/php.ini/PHP/display_errors On
set /files/etc/php5/apache2/php.ini/PHP/error_reporting "E_ALL | E_STRICT"
save
EOF

service mysql restart

# database
mysql -u root -proot <<EOF
CREATE DATABASE IF NOT EXISTS vagrant_va;
GRANT ALL ON *.* TO root IDENTIFIED BY 'root';
EOF

# mysql tmpfs (speeds up installs, db loads, etc)
if [ ! -d /var/lib/.mysql ]; then
  service mysql stop
  cp -a /var/lib/mysql/ /var/lib/.mysql
  cp /vagrant/vagrant/init-mysql.conf /etc/init/mysql.conf
  service mysql start
fi

# set up mysql client configuration
if [ ! -f "/home/vagrant/.my.cnf" ]; then
  ln -s /vagrant/vagrant/my.cnf /home/vagrant/.my.cnf
fi

# apache vhost
a2enmod rewrite
if ! grep -iq vagrant /etc/apache2/sites-available/default; then
  cat /vagrant/vagrant/vhost.conf > /etc/apache2/sites-available/default
  apache2ctl restart
fi

# add links to vagrant-specific settings.php
for site in va; do
  cp /vagrant/vagrant/settings.php "/server/htdocs/sites/$site/"
  chmod -R 777 "/server/htdocs/sites/$site/files"
done

# fix broken locale/LANG warning
sudo update-locale LC_ALL=en_US.UTF-8

# make sure vagrant ssh puts us in the drupal directory
if ! grep -iq "^cd /server/htdocs" ~vagrant/.bashrc; then
  cat >> ~vagrant/.bashrc <<EOF
# get into drupal at login
cd /server/htdocs
EOF
fi

if [ ! -f ~vagrant/.ssh/config ] ; then
	touch ~vagrant/.ssh/config
fi

if ! grep -iq 'User' ~vagrant/.ssh/config; then
	cat >> ~vagrant/.ssh/config  << EOF
Host *
User $1
StrictHostKeyChecking no
EOF
fi

# Set up bashrc and fancy git-friendly prompts
cp /vagrant/vagrant/bashrc /root/.bashrc
cp /vagrant/vagrant/git-prompt.sh /root/.git-prompt.sh
cp /vagrant/vagrant/bashrc ~vagrant/.bashrc
cp /vagrant/vagrant/git-prompt.sh ~vagrant/.git-prompt.sh
chown -R vagrant:vagrant ~vagrant

# set up
