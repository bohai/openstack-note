pci passthrough
----

pci passthrough(VFIO)
----

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
