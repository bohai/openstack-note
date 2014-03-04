Openstack快照
----
###当前能力
+ 支持功能
    + 卷快照(支持一致性快照）
    + 虚拟机快照（支持冷快照和live snapshot with no downtime)
+ 卷快照
```shell
cinder snapshot-create
```
支持通过qemu-ga完成自动一致性操作（fsfreeze)  
+ 虚拟机快照制作过程
```shell    
nova image-create
```
+ 虚拟机[live snapshot]过程
（QEMU 1.3+ and libvirt 1.0+ ）
```shell    
guest:
sync         #刷脏数据到磁盘
fsfreeze -f  #锁定文件系统
host:
nova image-create #创建快照
guest:
fsfreeze -u  #解除锁定文件系统
```
+ 当前限制
openstack的虚拟机快照只快照root盘，不快照内存/CPU状态以及挂载磁盘。
挂载磁盘需要事先卸载磁盘(数据盘），然后进行快照，然后再挂载磁盘。

+ 虚拟机快照缺点：  
    +  不支持内存快照 
    +  只对系统盘进行快照 
    +  没有快照链信息 
    +  需要用户进行一致性操作 
    +  不支持含元数据导出 
    +  不支持含元数据导入
    +  只支持虚拟机全量数据快照（与快照的实现方式有关，因为是通过image进行保存的）
    +  快照以Image方式保存，而非以cinder卷方式保存
    +  过程较长（需要先通过存储快照，然后抽取并上传至glance)。
    +  无法充分利用存储本身能力加快快照的创建和使用

+ nova image-create的流程
    1.  获取token（获取token接口）  
    2.  查询虚拟机状态（查询接口）  
    3.  创建虚拟机快照 
```shell
curl -i http://186.100.8.214:8774/v2/86196260e1694d0cbb5049cfba3883f8/servers/6c2504f4-efa-47ec-b6f4-06a9fde8a00b/action -X POST -H "X-Auth-Project-Id: admin" -H "User-Agent: python-novaclient" -H "Content-Type: application/json" -H "Accept: application/json" -H "X-Auth-Token: " -d '{"createImage": {"name": "nova_100_new_01", "metadata": {}}}'
```
    4.  volume backed的虚拟机，使用compute_api.snapshot_volume_backed创建虚拟机快照；volume backed以外类型的虚拟机，调用compute_api.snapshot接口创建快照（最终实现在createImage接口） 
+ createImage接口（创建虚拟机快照）流程   
```shell
底层实现：
a. 清理block设备上次的job信息
[root@fedora170 data]# virsh blockjob test /data/test/test.qcow2 --abort
error: Requested operation is not valid: No active operation on device: drive-virtio-disk0

b. 创建基于block设备backing_file的qcow2文件
[root@fedora170 data]# qemu-img create -f qcow2 -o backing_file=/data/test/test.qcow2,cluster_size=65536,size=20G /data/test/test.qcow2.delta
Formatting '/data/test/test.qcow2.delta', fmt=qcow2 size=21474836480 backing_file='/data/test/test.qcow2' encryption=off cluster_size=65536 lazy_refcounts=off

c. persist类型的虚拟机，进行undefine
d. 将block数据拷贝到新做的qcow2文件上
[root@fedora170 data]# virsh blockcopy test /data/test/test.qcow2 /data/test/test.qcow2.delta 0 --shallow --reuse-external
Block Copy started

e. 查询进度，等待block job完成
[root@fedora170 data]# virsh blockjob test /data/test/test.qcow2 --info
Block Copy: [100 %]

f. 清理block设备上次的job信息
[root@fedora170 data]# virsh blockjob test /data/test/test.qcow2  --abort

g. persist类型的虚拟机，重新define
h. 抽取整个block的数据到新的qcow2文件中（后续可以上传到glance上）
[root@fedora170 data]# qemu-img convert -f qcow2 -O qcow2 -c /data/test/test.qcow2.delta /data/test/test_snapshot.qcow2
```

### 当前快照导入、导出方法
+ 虚拟机快照导出
    1.  使用nova image-create创建虚拟机快照
    2.  通过glance image-download <Image ID> --file filename.img导出虚拟机快照
+ 虚拟机快照导入
    1.  通过glance image-create --file导入虚拟机快照
[live snapshot]:http://docs.openstack.org/trunk/openstack-ops/content/snapshots.html


###虚拟机快照当前的BP
-  包含内存、CPU状态等数据的快照。  
该BP目前计划解决该问题（目前代码已经完成，在review中）：  
https://blueprints.launchpad.net/nova/+spec/live-snapshot-vms  
实现方式：
通过glance container来存储instance的root盘、内存快照、虚拟机xml信息等。  

-  虚拟机所有盘的快照。  
该BP还在draft解决，完全没有开始：  
https://blueprints.launchpad.net/nova/+spec/instance-level-snapshots

###待完善
+ 快照树  
  目前虚拟机快照未保存快照链信息，只能知道时间先后顺序，无法知道快照关系。
  (因为是全量快照，暂时不需要。）
+ 导出包含metadata的image  
  便于后续重新导入image
+ 增量快照   
  虚拟机增量快照（与目前机制相差较大，影响大）

###其他
openstack和版本对快照的思路略有不同。openstack因为存在镜像管理，所以虚拟机快照更多的是
通过镜像方式管理。而版本不存在镜像管理，更多的是通过存储来保存和使用镜像。

###BP列表
+ 在线虚拟机快照（包含内存、CPU状态）   开发中  Next  
https://blueprints.launchpad.net/nova/+spec/live-snapshot-vms
+ Live snapshot基础能力                                   完成  
https://blueprints.launchpad.net/nova/+spec/live-snapshots
+ libvirt无中断快照                                            完成  
https://blueprints.launchpad.net/nova/+spec/libvirt-live-snapshots
+ Qemu辅助卷快照（带内部VSS等？只支持一致性卷快照而非虚拟机）           完成  
https://blueprints.launchpad.net/nova/+spec/qemu-assisted-snapshots
https://wiki.openstack.org/wiki/Cinder/GuestAssistedSnapshotting
+ Instacne全卷快照：                                        draft阶段  
https://blueprints.launchpad.net/nova/+spec/instance-level-snapshots
+ Lined clone：                                                 draft阶段  
https://blueprints.launchpad.net/nova/+spec/linked-snapshot
+ 感觉像是利用linked clone快速clone虚拟机  
https://blueprints.launchpad.net/nova/+spec/nova-fast-snapshot

+ 关联的一个重要BP  
https://wiki.openstack.org/wiki/Raksha

###备注 
[1]: http://docs.openstack.org/user-guide/content/cli_manage_images.html#glance-image-list 
[2]: http://docs.openstack.org/trunk/openstack-ops/content/snapshots.html  
[3]: http://www.sebastien-han.fr/blog/2012/12/10/openstack-perform-consistent-snapshots/
[4]: http://docs.openstack.org/image-guide/content/

[底层原理过程]:http://kashyapc.com/tag/snapshots/

