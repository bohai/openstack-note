openstack tricks
---

###使用curl发送消息：
+ [root@controller ~(keystone_admin)]# nova --debug image-create 6c2504f4-efa9-47ec-b6f4-06a9fde8a00b nova_100_new_01
+ 获取token：  
```xml
curl -i http://186.100.8.214:35357/v2.0/tokens -X POST -H "Content-Type: application/json" -H "Accept: application/json" -H "User-Agent: python-novaclient" -d '{"auth": {"tenantName": "admin", "passwordCredentials": {"username": "admin", "password": "admin"}}}'
```
+ 获取虚拟机信息：  
```xml
curl -i http://186.100.8.214:8774/v2/86196260e1694d0cbb5049cfba3883f8/servers/6c2504f4-efa9-47ec-b6f4-06a9fde8a00b -X GET -H "X-Auth-Project-Id: admin" -H "User-Agent: python-novaclient" -H "Accept: application/json" -H "X-Auth-Token: "
```
+ 创建image：  
```xml
curl -i http://186.100.8.214:8774/v2/86196260e1694d0cbb5049cfba3883f8/servers/6c2504f4-efa9-47ec-b6f4-06a9fde8a00b/action -X POST -H "X-Auth-Project-Id: admin" -H "User-Agent: python-novaclient" -H "Content-Type: application/json" -H "Accept: application/json" -H "X-Auth-Token: " -d '{"createImage": {"name": "nova_100_new_01", "metadata": {}}}'
```

+ json可读显示
```xml
curl命令 | python -mjson.tool
```

###查看mysql数据库：
+ 登陆：  
$ mysql -uroot -p
+ 查询数据库：  
mysql>show databases;
+ 查看某个数据库：  
mysql>use database名;
+ 查看数据库中的表：  
mysql>show tables; 
+ 查看表中的数据：  
mysql>select * from table名;
+ 查看表结构：  
mysql>desc table名;

###pdb调试
两种方式运行：
+ python -m pdb myscript.py
+ 代码中添加pdb
```python
          import pdb
          pdb.set_trace()
```
pdb支持的指令以及指令详细用法可以通过help查看。

### 邮件搜索  
http://openstack.markmail.org/


