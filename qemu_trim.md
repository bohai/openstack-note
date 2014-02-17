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

+ trim实现原理  
参照http://leiqzhang.com/2013/08/2013-08-07-virtual-disk-unmap-shrink/


+ 使用场景  
虚拟化场景下节省存储空间。尤其是用于IO负荷低（数据使用频率低）的存储，用户删除数据后后端回收空间从而提高空间使用率。


