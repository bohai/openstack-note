ALL IN ONE:
---
```shel
1. 配置外网访问，repo
2. 安装前配置
adduser stack
sudo stack
apt-get install sudo -y || yum install -y sudo
echo "stack ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
sudo apt-get install git -y || yum install -y git
git clone https://github.com/openstack-dev/devstack.git
cd devstack

3. local.conf定制
拷贝并修改local.conf到stack.sh同级目录

4. 安装
./stack.sh
```
