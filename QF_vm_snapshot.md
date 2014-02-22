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
快照元信息保存在/var/lib/libvirt/qemu/snapshot/中。  
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

### 参考
[Atomic Snapshots of Multiple Devices]:http://wiki.qemu.org/Features/SnapshotsMultipleDevices
[Snapshots]:http://wiki.qemu.org/Features/Snapshots
[Libvirt snapshot]:http://wiki.libvirt.org/page/Snapshots
[Fedora virt snapshot]:https://fedoraproject.org/wiki/Features/Virt_Live_Snapshots
[Libvirt live snapshot]:http://kashyapc.com/2012/09/14/externaland-live-snapshots-with-libvirt/
[kvm快照浅析]:http://itxx.sinaapp.com/blog/content/130
[1]:http://blog.sina.com.cn/s/blog_53ab41fd01013rc0.html
[2]:http://blog.csdn.net/gg296231363/article/details/6899533
