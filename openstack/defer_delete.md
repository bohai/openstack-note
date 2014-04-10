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
删除镜像fedora_s2。
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
查看数据库信息, fedora_s2的状态为pending_delete。
```shell
+--------------------------------------+-----------+-----------+----------------+-----------+---------------------+---------------------+---------------------+---------+-------------+------------------+----------------------------------+----------------------------------+----------+---------+-----------+
| id                                   | name      | size      | status         | is_public | created_at          | updated_at          | deleted_at          | deleted | disk_format | container_format | checksum                         | owner                            | min_disk | min_ram | protected |
+--------------------------------------+-----------+-----------+----------------+-----------+---------------------+---------------------+---------------------+---------+-------------+------------------+----------------------------------+----------------------------------+----------+---------+-----------+
| f01af3f9-58c3-463d-bf66-fb58825466b4 | fedora_s2 | 983629824 | pending_delete |         0 | 2014-02-15 15:03:22 | 2014-04-10 17:51:53 | 2014-04-10 17:51:53 |       1 | qcow2       | bare             | c5870838c1c85547d5b85084071db21a | 86196260e1694d0cbb5049cfba3883f8 |       20 |    2048 |         0 |
+--------------------------------------+-----------+-----------+----------------+-----------+---------------------+---------------------+---------------------+---------+-------------+------------------+----------------------------------+----------------------------------+----------+---------+-----------+

```

备注：目前image找回功能的接口还在review中，目前仍不可用。  
+ 实现原理  
实现原理很简单。当打开延迟删除开关后，对image的删除不会立刻触发动作，
而只是记录的状态为pending_delete和删除时间。  
另外glance有个scrubber的清理服务，会周期性检查pending_delete的image是否到期，
到期则进行删除动作。 


#### glance镜像的删除保护
+ 用法  
设置镜像保护是个admin操作，操作方法见如下：  
```shell
[root@controller ~(keystone_admin)]# glance image-update --is-protected True centos_wc
+------------------+--------------------------------------+
| Property         | Value                                |
+------------------+--------------------------------------+
| checksum         | 2f7476ac2fe077979d2f0cda7640d1a8     |
| container_format | bare                                 |
| created_at       | 2014-04-03T10:45:19                  |
| deleted          | False                                |
| deleted_at       | None                                 |
| disk_format      | raw                                  |
| id               | a7f49865-0388-48f1-a547-f6f23066fb4f |
| is_public        | False                                |
| min_disk         | 0                                    |
| min_ram          | 0                                    |
| name             | centos_wc                            |
| owner            | 86196260e1694d0cbb5049cfba3883f8     |
| protected        | True                                 |
| size             | 10737418240                          |
| status           | active                               |
| updated_at       | 2014-04-10T19:00:29                  |
+------------------+--------------------------------------+
[root@controller ~(keystone_admin)]# glance image-delete centos_wc
Request returned failure status.
403 Forbidden
Image is protected
    (HTTP 403): Unable to delete image centos_wc
```
+ 实现原理   
通过image的属性“protected”进行控制。  
删除前检查该属性，未保护则可以删除。保护则不可以删除。   
需要先将属性“protected”修改为“False“才能删除。  

#### nova虚拟机的软删除
+ 用法
通过nova.conf，设置回收已删除虚拟机的间隔。  
```xml
# Interval in seconds for reclaiming deleted instances
# (integer value)
#reclaim_instance_interval=0
```
该值为0，则立刻删除。不为0，则为软删除。  
在该时间到达前，可以通过API将虚拟机找回。  
周期性任务_reclaim_queued_deletes会定期检查，真正删除已经到达时间的虚拟机。

相关API：
```
# 强制删除（会对虚拟机立刻删除）
POST v2/​{tenant_id}​/servers/​{server_id}​/action
{
    "forceDelete": null
}

# 找回
POST v2/​{tenant_id}​/servers/​{server_id}​/action
{
    "restore": null
}
```
+ 实现原理   
实现原理比较简单，通过虚拟机数据库中的状态进行软删除控制。  
通过定时任务进行虚拟机的删除。  
