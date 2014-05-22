#!/usr/bin/env bash
STACK_TEMPLATE="/template/db"
ROOT_PASSWORD="admin"
HOST_OLD_IP="186.100.30.214"
HOST_NEW_IP="186.100.30.215"

service mysqld restart
chkconfig mysqld on
mysqladmin -u root password ${ROOT_PASSWORD}

#create database
mysql -uroot -p$ROOT_PASSWORD -h127.0.0.1 -e "CREATE DATABASE neutron;"
mysql -uroot -p$ROOT_PASSWORD -h127.0.0.1 -e "CREATE DATABASE glance;"
mysql -uroot -p$ROOT_PASSWORD -h127.0.0.1 -e "CREATE DATABASE heat;"
mysql -uroot -p$ROOT_PASSWORD -h127.0.0.1 -e "CREATE DATABASE keystone;"
mysql -uroot -p$ROOT_PASSWORD -h127.0.0.1 -e "CREATE DATABASE cinder;"
mysql -uroot -p$ROOT_PASSWORD -h127.0.0.1 -e "CREATE DATABASE nova;"


#import openstak database
mysql -u root -p${ROOT_PASSWORD} mysql     < ${STACK_TEMPLATE}/mysql.sql
mysql -u root -p${ROOT_PASSWORD} cinder    < ${STACK_TEMPLATE}/cinder.sql
mysql -u root -p${ROOT_PASSWORD} glance    < ${STACK_TEMPLATE}/glance.sql
mysql -u root -p${ROOT_PASSWORD} heat      < ${STACK_TEMPLATE}/heat.sql
sed  -i "s/${HOST_OLD_IP}/${HOST_NEW_IP}/g"  ${STACK_TEMPLATE}/keystone.sql
mysql -u root -p${ROOT_PASSWORD} keystone  < ${STACK_TEMPLATE}/keystone.sql
mysql -u root -p${ROOT_PASSWORD} neutron   < ${STACK_TEMPLATE}/neutron.sql
mysql -u root -p${ROOT_PASSWORD} nova      < ${STACK_TEMPLATE}/nova.sql

#remove_anonymous_users
mysql -uroot -p$ROOT_PASSWORD -h127.0.0.1 -e "DELETE FROM mysql.user WHERE User='';"
#remove_remote_root
mysql -uroot -p$ROOT_PASSWORD -h127.0.0.1 -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
#remove_test_database
mysql -uroot -p$ROOT_PASSWORD -h127.0.0.1 -e "DROP DATABASE test;DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
#reload_privilege_tables
mysql -uroot -p$ROOT_PASSWORD -h127.0.0.1 -e "FLUSH PRIVILEGES;"

#truncate table compute_nodes in nova
mysql -uroot -p$ROOT_PASSWORD -h127.0.0.1 -e "TRUNCATE table nova.compute_nodes;"


service mysqld restart
