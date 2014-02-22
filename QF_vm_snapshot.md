快照分类
-----
+ 磁盘快照  
对磁盘数据进行快照。主要用于虚拟机备份等场合。  
    + 按快照信息保存为可以可以分为：  
        + 内置快照  
            快照数据和base磁盘数据放在一个qcow2文件中。  
        + 外置快照  
            快照数据单独的qcow2文件存放。  
    + 按虚拟机状态可以分为:  
        + 关机态快照  
            数据可以保证一致性。  
        + 运行态快照  
            数据无法保证一致性，类似与系统crash后的磁盘数据。使用是可能需要fsck等操作。  
    + 按磁盘数量可以分为        
        + 单盘  
            单盘快照不涉及原子性。  
        + 多盘  
            涉及原子性。主要分两个方面：1.是所有盘快照点相同 2.所有盘要么都快照成功，要么都快照失败。  
            主要依赖于qemu的transaction实现。  
        
+ 内存快照  
对虚拟机的内存/设备信息进行保存。该机制同时用于休眠恢复，迁移等场景。    
主要使用virsh save（qemu migrate to file）实现。    
只能对运行态的虚拟机进行。 

+ 检查点快照    
同时保存虚拟机的磁盘快照和内存快照。用于将虚拟机恢复到某个时间点。可以保证数据的一致性。  


内置快照
-----
### 利用qemu-img   
```shell
qemu-img snapshot -c snapshot01 test.qcow2  //创建
qemu-img snapshot -l test.qcow2             //查看
qemu-img snapshot -a snapshot01 test.qcow2  //revert到快照点
qemu-img snapshot -d snapshot01 test.qcow2  //删除

```
### 利用Libvirt     
```xml
snapshot.xml
  <domainsnapshot>
    <name>snapshot01</name>
    <description>Snapshot of OS install and updates by boh</description>
    <disks>
      <disk name='/data/os-multi/controller.qcow2'>
      </disk>
    </disks>
  </domainsnapshot>
  
virsh snapshot-create controller snapshot.xml  //创建快照。快照元信息在/var/lib/libvirt/qemu/snapshot/（destroy后丢失）
virsh snapshot-list controller --tree          //树形查看快照。
virsh snapshot-current controller              //查看当前快照
virsh snapshot-revert controller snapshot02    //恢复快照
virsh snapshot-delete controller snapshot02    //删除快照

功能参数：
    --quiesce        quiesce guest's file systems
    --atomic         require atomic operation

```

外置快照  
------
### 利用qemu-img   
+ 关机态  
可以利用qcow2的backing_file创建。  
+ 运行态  
可以利用qemu的snapshot_blkdev命令。（为了数据一致性，可以使用guest-fsfreeze-freeze和guest-fsfreeze-thaw进行文件系统的冻结解冻结操作）  
多盘可以利用qemu的transaction实现atomic。  

### 利用libvirt  
+ 创建  
```shell
virsh snapshot-create-as --domain f17-base snap1 snap1-desc \
--disk-only --diskspec vda,snapshot=external,file=/export/vmimages/sn1-of-f17-base.qcow2 \
--atomic
# virsh domblklist f17-base
Target     Source
----------------------------------------------------
vda        /export/vmimages/sn1-of-f17-base.qcow2
```
+ 删除(快照链缩短）  
外置快照的删除，相对于内置快照稍显复杂。  
主要利用blockcommit或者blockpull来实现。  
blockcommit是向base方向合并，blockpull则相反。  
```shell
virsh blockcommit --domain f17 vda  --base /export/vmimages/sn2.qcow2 --top /export/vmimages/sn3.qcow2 --wait --verbose

#只支持pull到最前端  
virsh blockpull --domain RootBase --path /var/lib/libvirt/images/active.qcow2  \
  --base /var/lib/libvirt/images/RootBase.qcow2 --wait --verbose
virsh snapshot-delete --domain RootBase Snap-3 --metadata         #删除无用的快照

```
### 其他方法
利用LVM创建。利用文件系统能力创建。利用存储本身的功能创建。  

### 参考
[Atomic Snapshots of Multiple Devices]:http://wiki.qemu.org/Features/SnapshotsMultipleDevices
[Snapshots]:http://wiki.qemu.org/Features/Snapshots
[Libvirt snapshot]:http://wiki.libvirt.org/page/Snapshots
[Fedora virt snapshot]:https://fedoraproject.org/wiki/Features/Virt_Live_Snapshots
[Libvirt live snapshot]:http://kashyapc.com/2012/09/14/externaland-live-snapshots-with-libvirt/
[kvm快照浅析]:http://itxx.sinaapp.com/blog/content/130
[1]:http://blog.sina.com.cn/s/blog_53ab41fd01013rc0.html
[2]:http://blog.csdn.net/gg296231363/article/details/6899533
[libvirt snapshot讲的最好]:http://libvirt.org/formatsnapshot.html

```shell
#libvirt的虚拟机快照实现过程：
optionally - use the guest-agent to tell the guest OS to quiesce I/O
tell qemu to migrate guest memory to file; qemu pauses guest
for each disk:
  tell qemu to pause disk image modifications for that disk
libvirt resumes qemu (but I/O is still frozen)
for each disk:
  libvirt creates the snapshot
  if the snapshot involves updating the backing image used by qemu:
    pass qemu the new fd for the disk image
  tell qemu to resume disk I/O on that disk

#虚拟机快照恢复实现过程：

for each disk:
  revert back to disk snapshot point
tell qemu to do incoming migration from file
```
