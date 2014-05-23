#!/usr/bin/env bash
STACK_TEMPLATE="/etc/template/db/"

mysqldump -u root -padmin cinder    > ${STACK_TEMPLATE}/cinder.sql
mysqldump -u root -padmin glance    > ${STACK_TEMPLATE}/glance.sql
mysqldump -u root -padmin heat      > ${STACK_TEMPLATE}/heat.sql
mysqldump -u root -padmin keystone  > ${STACK_TEMPLATE}/keystone.sql
mysqldump -u root -padmin neutron   > ${STACK_TEMPLATE}/neutron.sql
mysqldump -u root -padmin nova      > ${STACK_TEMPLATE}/nova.sql
mysqldump -u root -padmin mysql     > ${STACK_TEMPLATE}/mysql.sql
