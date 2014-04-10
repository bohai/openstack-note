ALL IN ONE:
----
devstack通过外网安装openstack。  
```shel
1. 配置ccproxy外网访问

2. 拷贝163的fedora repo到/etc/yum.repos.d/

3. 安装前配置
adduser stack
sudo stack
apt-get install sudo -y || yum install -y sudo
echo "stack ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
sudo apt-get install git -y || yum install -y git
git clone https://github.com/openstack-dev/devstack.git
cd devstack

4. local.conf定制
拷贝local.conf到stack.sh同级目录
修改local.conf

5. 修改localrc，修改git库协议为http

6. 安装
./stack.sh

7. 关闭防火墙
setenforce 0
service iptables stop
chkconfig iptables off

8. 服务随主机启动
chkconfig rabbitmq-server on
service rabbitmq-server start
chkconfig httpd on
service httpd start
chkconfig mysqld on
service mysqld start
chkconfig openvswitch on
service openvswitch start

9. 重启后处理
恢复卷组和准备cinder-volume： 
losetup -f /opt/stack/data/stack-volumes-backing-file 
rejoin-stack.sh

```
