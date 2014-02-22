快照分类
-----
+ 内置快照  
    一个qcow2文件中即保存原始数据，又保存快照信息。
    + 磁盘快照
        + 关机态  
            libvirt使用qemu-img命令创建  
        + 运行态  
            libvirt使用savevm命令创建 
    + 检查点快照  
            libvirt使用savevm命令创建
+ 外置快照
    快照信息保存在单独的文件中。
    + 磁盘快照 
        + 关机态
            libvirt使用qemu-img命令创建
        + 运行态
            libvirt使用transaction命令创建？（没找到，待确认）
    + 检查点快照
    虚拟机的磁盘状态保存在一个文件中。内存和设备状态保存在另一个文件中。  
        开发中？
+ 备注   
    可以将虚拟机内存设备状态保存在文件中，然后使用该文件恢复，可以恢复到当时的状态。  
    使用qemu的migrate(to file)完成信息的转储。  


内置快照
-----
单个qcow2中包括了数据和快照状态信息。    
可以明显的看到qcow2文件增大。
### qemu-img创建卷快照 
+ 创建快照  
```shell
qemu-img snapshot -c snapshot01 test.qcow2
```
+ 查看快照  
```shell
qemu-img snapshot -l test.qcow2
```

+ revert到快照点 
```shell
qemu-img snapshot -a snapshot01 test.qcow2
```

+ 删除快照   
```shell 
qemu-img snapshot -d snapshot01 test.qcow2
```
### Libvirt创建虚拟机快照  
+ snapshot.xml  
```xml
  <domainsnapshot>
    <name>snapshot01</name>
    <description>Snapshot of OS install and updates by boh</description>
    <disks>
      <disk name='/data/os-multi/controller.qcow2'>
      </disk>
    </disks>
  </domainsnapshot>
```
+ 制作快照
```shell 
virsh snapshot-create controller snapshot.xml
```
+ 查看快照  
快照元信息保存在/var/lib/libvirt/qemu/snapshot/中(虚拟机destroy后会丢失)。  
```shell
[root@fedora170 snapshot]# virsh snapshot-list controller
 Name                 Creation Time             State
------------------------------------------------------------
 snapshot01           2014-02-22 11:24:04 +0800 running
[root@fedora170 snapshot]# ls -l /var/lib/libvirt/qemu/snapshot/controller/
total 8
-rw------- 1 root root 4768 Feb 22 11:26 snapshot01.xml
```
+ 查看当前快照信息  
```shell
virsh snapshot-current controller
```
+ 恢复、删除快照信息  
```shell
virsh snapshot-revert controller snapshot02
virsh snapshot-delete controller snapshot02
```
+ 快照还支持多盘原子组、guest文件系统freeze、仅磁盘快照（需要qemu-ga支持）     
```shell
    --disk-only      capture disk state but not vm state
    --quiesce        quiesce guest's file systems
    --atomic         require atomic operation
```
外置快照
------
### qemu创建快照
### libvirt创建快照  


### 参考
[Atomic Snapshots of Multiple Devices]:http://wiki.qemu.org/Features/SnapshotsMultipleDevices
[Snapshots]:http://wiki.qemu.org/Features/Snapshots
[Libvirt snapshot]:http://wiki.libvirt.org/page/Snapshots
[Fedora virt snapshot]:https://fedoraproject.org/wiki/Features/Virt_Live_Snapshots
[Libvirt live snapshot]:http://kashyapc.com/2012/09/14/externaland-live-snapshots-with-libvirt/
[kvm快照浅析]:http://itxx.sinaapp.com/blog/content/130
[1]:http://blog.sina.com.cn/s/blog_53ab41fd01013rc0.html
[2]:http://blog.csdn.net/gg296231363/article/details/6899533
