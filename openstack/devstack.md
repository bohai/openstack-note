ALL IN ONE:
---
```shel
adduser stack
sudo stack
apt-get install sudo -y || yum install -y sudo
echo "stack ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
sudo apt-get install git -y || yum install -y git
git clone https://github.com/openstack-dev/devstack.git
cd devstack
拷贝并修改local.conf到stack.sh同级目录
./stack.sh
```
