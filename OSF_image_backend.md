### openstack image backend
目前openstack提供了raw,qcow2,lvm,rbd四种类型的image后端。    
所谓后端，即image/临时卷root盘的管理存储方式。  

![alter image](http://www.pixelbeat.org/docs/openstack_libvirt_images/openstack-libvirt-images.png)

nova/virt/libvirt/imagebackend.py：  
中有四个Raw,Qcow2,Lvm,Rbd四个类，均继承了image类，主要提供create_image方法和snapshot_extract方法。  
image父类提供了cache方法，会调用create_image方法。  
cache方法提供了image目录创建，调用create_image方法创建image, 完成preallocate（通过fallocate实现）。  
create_image方法提供了image下载，根据backend类型不同进行backing_image创建的能力。  
backend类主要提供对Raw，Qcow2, Lvm, Rbd的对象生成能力。  


cache方法的调用流：

cache方法《------_create_image方法《------------------(rescue/finish_migration/spawn)    
cache方法《------_create_images_and_backing方法《-----(hard_reboot/pre_livemigration)        


配置项:
images_type  用于配置默认的image存储管理方式。可以设置为四种类型的任意一种。  
volume_clear 用于定义临时卷删除的方式（各种安全删除策略）。  
volume_clear_size 用于shred删除方式删除时破坏数据的大小。  

注：版本现在的能力缺陷。  
