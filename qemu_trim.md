###libvirt/qemu  文件系统trim
目前virtio驱动无法支持trim，ide/scsi/virtio-scsi驱动可以支持trim。
qemu的trim特性：1.5版支持raw，1.6版支持qcow2。
NTFS本身支持trim命令，EXT4需要在mount时指定参数-o discard，EXT3需要手工执行fstrim。
+ libvirt方式启动虚拟机
```xml
    <disk type='file' device='disk'>
        <driver name='qemu' type='qcow2' cache='none' discard='unmap'/>
        <source file='/data/hotplug/vdb.qcow2'/>
        <target dev='sdb' bus='ide'/>
    </disk>
```

+ qemu直接启动虚拟机
```shell
./qemu-system-x86_64 --enable-kvm -m 2g -smp 2  -drive file=/data/hotplug/hotplug.qcow2,cache=none,if=ide,discard=on,format=qcow2 -drive file=/data/hotplug/vdb.qcow2,cache=none,if=ide,discard=on,format=qcow2  -vnc 186.100.8.138:-1
```

+ 确认方法  
虚拟机内部(文件系统挂载需要-o discard参数）：
```shell
mount -o discard /dev/sdb /mnt
```
在guest中/mnt下创建大文件：
```shell
[root@localhost hotplug]# du -hs vdb.qcow2
481M    vdb.qcow2
```
在guest中/mnt下删除大文件：
```shell
[root@localhost hotplug]# du -hs vdb.qcow2
294M    vdb.qcow2
```

+ Shrink实现原理  
参照http://leiqzhang.com/2013/08/2013-08-07-virtual-disk-unmap-shrink/   
虚拟机磁盘设备Shrink过程：  
>guest fs----->device driver----->qemu block----->host fs---->host device driver----->device

+ 使用场景    
提供空间使用率。  
提高写数据性能。  

+参考  
为什么引入trim命令：  
http://www.360doc.com/content/11/0723/10/7040275_135349919.shtml  
为什么引入unmap命令：  
主要为了应对thin provision场景的存储使用效率。  

