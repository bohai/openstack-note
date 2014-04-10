openstack中的延迟删除、软删除、删除保护
-----
#### glance镜像的延迟删除
+ 用法  
glance-api.conf中打开延迟删除开关
``` xml
# Turn on/off delayed delete
delayed_delete = False
 
# Delayed delete time in seconds
scrub_time = 43200
```
使用nova image-delete删除image。  
然后通过nova image-list看不到被删除的iamge。  
通过glance数据库，可以看到该image的status为“pending_delete”。  
```
[root@controller ~(keystone_admin)]# glance image-list
+--------------------------------------+-----------+-------------+------------------+-------------+--------+
| ID                                   | Name      | Disk Format | Container Format | Size        | Status |
+--------------------------------------+-----------+-------------+------------------+-------------+--------+
| 42d61acd-1ab3-4a7e-a14e-68ad6ba75215 | centos    | iso         | bare             | 358959104   | active |
| a7f49865-0388-48f1-a547-f6f23066fb4f | centos_wc | raw         | bare             | 10737418240 | active |
| f01af3f9-58c3-463d-bf66-fb58825466b4 | fedora_s2 | qcow2       | bare             | 983629824   | active |
+--------------------------------------+-----------+-------------+------------------+-------------+--------+
[root@controller ~(keystone_admin)]# glance image-delete fedora_s2
[root@controller ~(keystone_admin)]# glance image-list
+--------------------------------------+-----------+-------------+------------------+-------------+--------+
| ID                                   | Name      | Disk Format | Container Format | Size        | Status |
+--------------------------------------+-----------+-------------+------------------+-------------+--------+
| 42d61acd-1ab3-4a7e-a14e-68ad6ba75215 | centos    | iso         | bare             | 358959104   | active |
| a7f49865-0388-48f1-a547-f6f23066fb4f | centos_wc | raw         | bare             | 10737418240 | active |
+--------------------------------------+-----------+-------------+------------------+-------------+--------+
```

备注：目前image找回功能的接口还在review中，目前仍不可用。  
+ 实现原理

#### glance镜像的删除保护
+ 用法
+ 实现原理


#### nova虚拟机的软删除
+ 用法
+ 实现原理
