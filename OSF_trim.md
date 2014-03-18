计划
------
    |内容                  |  进度|
----|----------------------|------|
0.  |openstack能力/bp调查  |  完成|
1.  |qemu/kvm能力验证      |  完成|
2.  |openstack实现原型||
3.  |BP提交|完成|
4.  |代码提交、review||

准备
------
###特性介绍  
qemu在1.5/1.6已经支持了raw和qcow2的[trim特性]。  
本文主要介绍在openstack中的实现。

###接口变化  
~~接口名：  
v2/​{tenant_id}​/servers/​{server_id}​/os-volume_attachments  
通过参数dict参数volumeAttachment传入是否开启trim。~~  

###典型使用方法  
1. 用户通过image metadata添加virtio-scsi controller或者ide设备  
    >hw_scsi_model=virtio-scsi/ide

2. 用户创建虚拟机   
3. 用户通过volume metadata添加discard, bus属性  
    > discard属性: hw_disk_discard=unmap/ignore  
    > bus属性：hw_disk_bus=scsi, virtio, uml, xen, ide, usb  

4. 用户将卷挂载给虚拟机  

### 代码流程  
+ image metadata支持[virtio-scsi controller]已经实现，目前在review中。预计i3合入。  
+ volume metadata支持discard属性（默认不开启）、bus属性（默认不设置）待开发（xml属性生成）。

### 如何向用户展现
1. 支持用户打开discard开关  
2. 触发discard，主要有三种方法
    1. 对NTFS/ext4有自动discard的，打开discard属性
    2. 对ext3这种不能自动discard的
        1. 用户手动触发
        2. 用户在guest内实现自动触发
        3. openstack向用户暴露接口，触发guest的trim，需要guest-agent支持
    

###笔记
+ volume attach：  
```xml
curl -i http://186.100.8.214:8774/v2/86196260e1694d0cbb5049cfba3883f8/servers/c62b5277-23cf-4af2-b6ae-15765e9341d1/os-volume_attachments -X GET -H "X-Auth-Project-Id: admin" -H "User-Agent: python-novaclient" -H "Accept: application/json" -H "X-Auth-Token: 2e3c783097fc4f07b2673f520f4d9962"
```
+ 缺失  
目前openstack底层未进行controller的指定。依靠libvirt自动生成。
但是特殊场景，由于需要制定controller的model类型，需要特别订制。

[trim特性]:QF_trim.md
[2]:https://wiki.openstack.org/wiki/BlockDeviceConfig
[virtio-scsi controller]:https://blueprints.launchpad.net/nova/+spec/libvirt-virtio-scsi-driver
