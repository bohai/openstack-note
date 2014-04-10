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

备注：目前image找回功能的接口还在review中，目前仍不可用。  
+ 实现原理

#### glance镜像的删除保护
+ 用法
+ 实现原理


#### nova虚拟机的软删除
+ 用法
+ 实现原理
