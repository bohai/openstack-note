### qemu-img创建卷快照 
这种方式创建的快照属于内部快照。即快照保存在卷文件中。  
可以明显的看到qcow2文件增大。
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
# Libvirt创建虚拟机快照  


### 参考
[Atomic Snapshots of Multiple Devices]:http://wiki.qemu.org/Features/SnapshotsMultipleDevices
[Snapshots]:http://wiki.qemu.org/Features/Snapshots
[Libvirt snapshot]:http://wiki.libvirt.org/page/Snapshots
[Fedora virt snapshot]:https://fedoraproject.org/wiki/Features/Virt_Live_Snapshots
[Libvirt live snapshot]:http://kashyapc.com/2012/09/14/externaland-live-snapshots-with-libvirt/
[kvm快照浅析]:http://itxx.sinaapp.com/blog/content/130
[1]:http://blog.sina.com.cn/s/blog_53ab41fd01013rc0.html
[2]:http://blog.csdn.net/gg296231363/article/details/6899533
