pci passthrough
----
+ 概念  
  - 允许guest排他使用host上的某个PCI设备，就像将该设备物理连接到guest上一样。  
+ 使用场景
  - 提升性能（如直通网卡和显卡）  
  - 降低延迟（避免数据丢失或丢祯）  
  - 直接利用bare-metal上设备的驱动 
+ 用法[1]  
需要CPU支持VT-d。主板也支持该技术。  
  - 预先配置：  
    + 打开bios中的VT-d设置。
    + 激活kernel中参数配置
      ```kernel /vmlinuz-2.6.18-190.el5 ro root=/dev/VolGroup00/LogVol00 rhgb quiet intel_iommu=on```
  - 通过virsh添加PCI设备  
    + 识别设备  
    ```# virsh nodedev-list --tree |grep pci```
    + 获取设备xml   
    ```# virsh nodedev-dumpxml pci_8086_3a6c```
    + detach设备  
    ```# virsh nodedev-dettach pci_8086_3a6c```
    + 修改虚拟机xml文件   
    + 告诉主机不要再使用该设备  
    ```$ readlink /sys/bus/pci/devices/0000\:00\:1d.7/driver```
    + 设置selinux  
    ```$ setsebool -P virt_manage_sysfs 1```
    + 启动虚拟机  

pci passthrough(VFIO)[2]
----
VFIO是pci passthrough的一种新技术。kernel3.6/qemu1.4以后支持。    
相对于传统方式，VFIO对UEFI支持更好。
VFIO技术实现了用户空间直接访问设备。无须root特权，更安全，功能更多。
http://lwn.net/Articles/509153/
http://lwn.net/Articles/474088/

pci sr-iov
----

pci hotplug
----
+ [应用场景]
  1.  可服务性：移除、替换已经故障的硬件。  
  2.  能力管理：增加更多的硬件、或者在多个虚拟机之间平衡硬件资源。    
  3.  增添资源来在硬件之间迁移虚拟化层。  
  4.  虚拟机上虚拟设备的热拔插。  

+ 问题  
  1. 如何查看vm中的pci设备与host的pic设备的关系？  
  2. pci hotplug对flavor的影响？对计费的影响？rebuild/evalute时如何处理丢失？  

+ test

IOMMU
----
![good](http://c.hiphotos.baidu.com/baike/w%3D268/sign=c02c322ea8d3fd1f3609a53c084f25ce/d31b0ef41bd5ad6e9f63c5ea81cb39dbb6fd3c13.jpg)
IOMMU：input/output memory management unit。  
连接DMA io bus和主存，完成从设备虚拟地址到物理地址的映射。以及提供对故障设备的内存保护的功能。  
+ 优点
  - 分配大块连续的物理地址    
  - 使旧设备（32bit设备）可以使用高位地址。（可以改善内存使用，提高性能）  
  - 内存保护，避免设备使用不属于它的地址  
  - 提供硬件中断remapping功能  
+ 缺点
  - 地址转换和管理开销带来的性能降级   
  - 消耗物理内存  


[应用场景]:https://lists.linux-foundation.org/pipermail/hotplug_sig/2005-August/001202.html
[1]:http://docs.fedoraproject.org/en-US/Fedora/13/html/Virtualization_Guide/chap-Virtualization-PCI_passthrough.html
[2]:http://www.redhat.com/archives/libvir-list/2013-March/msg00514.html
