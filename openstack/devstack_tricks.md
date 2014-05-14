1. 安装运行create-stack-user.sh脚本时，当前目录不要是devstack
2. 安装时如果提示pbr版本不对   
   运行pip install --upgrade pbr, pip install --upgrade setuptools
3. 安装时提示下载超时，可以使用pip install --upgrade安装失败的包
4. 安装时提示提示mysql没权限
   执行下列命令：
 service mysqld stop
 mysqld_safe --user=mysql --skip-grant-tables --skip-networking & 
 mysql -u root mysql 
 UPDATE user SET Password=PASSWORD() where USER='root';
 FLUSH PRIVILEGES;
 quit
 service mysqld stop
5. 
