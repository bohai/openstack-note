Huge Page
----
适合大内存/内存密集型型应用虚拟机的调优。  
减小也表尺寸，降低查找缓存（TLB)的cache-miss,加速VM内存转换。  
默认Page size 4K / Huge Page 2M    
### libvirt  
xml设置方法：（告诉hypervisor虚拟机内存使用hugepage分配）
```xml
<memoryBacking>
	<hugepages/>
</memoryBacking>
```

### [qemu设置方法]
```xml
-mem-prealloc -mem-path /dev/hugepages/libvirt/qemu 
```

### 内核参数  
通过内核参数***/proc/sys/vm/nr_hugepages***修改。

Transparent Huge Page
----
内核线程khugepaged周期性自动扫描内存，自动将地址连续可以合并的4KB的普通Page并成2MB的Huge Page。  

### Redhat系统  
通过内核参数***/sys/kernel/mm/redhat_transparent_hugepage/enabled***打开.  
### 其他Linux系统  
通过内核参数***/sys/kernel/mm/transparent_hugepage/enabled***打开.  


### 确认方法  
```shell
[root@localhost transparent_hugepage]# grep AnonHugePages /proc/meminfo
AnonHugePages:    405504 kB
[root@localhost transparent_hugepage]# virsh list
 Id    Name                           State
----------------------------------------------------
 2     numa                           running

[root@localhost transparent_hugepage]# virsh destroy 2
Domain 2 destroyed

[root@localhost transparent_hugepage]# grep AnonHugePages /proc/meminfo
AnonHugePages:         0 kB
```
[qemu设置方法]:http://pic.dhe.ibm.com/infocenter/lnxinfo/v3r0m0/index.jsp?topic=%2Fliaat%2Fliaattunconfighp.htm

Openstack现状
-----
BP已经有人提出，目前在实现中。通过metadata实现。    
https://blueprints.launchpad.net/nova/+spec/enable-libvirt-to-use-hugepages       
