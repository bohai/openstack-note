pci passthrough
----
+ 概念  
  - 允许guest排他使用host上的某个PCI设备，就像将该设备物理连接到guest上一样。  
+ 使用场景
  - 提升性能（如直通网卡和显卡）  
  - 保证通信质量（避免数据丢失或丢祯）
+ 用法  
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

pci passthrough(VFIO)
----
需要CPU支持VT-d。主板也支持该技术。


pci sr-iov
----

pci hotplug
----
### [应用场景]
1.  可服务性：移除、替换已经故障的硬件。  
2.  能力管理：增加更多的硬件、或者在多个虚拟机之间平衡硬件资源。    
3.  增添资源来在硬件之间迁移虚拟化层。  
4.  虚拟机上虚拟设备的热拔插。  

### 问题  
1. 如何查看vm中的pci设备与host的pic设备的关系？  
2. pci hotplug对flavor的影响？对计费的影响？rebuild/evalute时如何处理丢失？  

### test

IOMMU
----
![iommu](http://imgt3.bdstatic.com/it/u=3939070475,3428034962&fm=21&gp=0.jpg)


[应用场景]:https://lists.linux-foundation.org/pipermail/hotplug_sig/2005-August/001202.html
