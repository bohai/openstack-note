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
VFIO在kernel3.6/qemu1.4以后支持,目前只支持PCI设备。  
VFIO是一套用户态驱动框架，提供两种基本服务：    
  + 向用户态提供设备访问接口  
  + 向用户态提供配置IOMMU接口  

VFIO可以用于实现高效的用户态驱动。在虚拟化场景可以用于device passthrough。  
通过用户态配置IOMMU接口，可以将DMA地址空间映射限制在进程虚拟空间中。  
这对高性能驱动和虚拟化场景device passthrough尤其重要。  

相对于传统方式，VFIO对UEFI支持更好。  
VFIO技术实现了用户空间直接访问设备。无须root特权，更安全，功能更多。  
http://lwn.net/Articles/509153/
http://lwn.net/Articles/474088/
https://www.ibm.com/developerworks/community/blogs/5144904d-5d75-45ed-9d2b-cf1754ee936a/entry/vfio?lang=en

+ 操作方法

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
![IOMMU](http://c.hiphotos.baidu.com/baike/w%3D268/sign=c02c322ea8d3fd1f3609a53c084f25ce/d31b0ef41bd5ad6e9f63c5ea81cb39dbb6fd3c13.jpg)   
IOMMU：input/output memory management unit。  
连接DMA io bus和主存，完成从设备虚拟地址到物理地址的映射。以及提供对故障设备的内存保护的功能。  
+ 优点
  - 由于IOMMU的映射，可以将多个不连续的物理地址映射为大块连续的地址供设备使用，便于简化驱动设计    
  - 使旧设备（32bit设备）可以使用高位地址。（可以改善内存使用，提高性能）  
  - 内存保护，避免设备使用不属于它的地址  
  - 提供硬件中断remapping功能  
+ 缺点
  - 地址转换和管理开销带来的性能降级   
  - 消耗物理内存  
+ 虚拟化中的应用  
  一般来说，由于内存地址不同，虚拟机中的操作系统无法直接访问host上的设备。  
通过IOMMU，可以将设备地址在虚拟机中和host中映射为相同的支持，供虚拟机使用。这种做法也可以缓解IO delay。

VMDQ[3]
----
Virtual Machine Device Queues[4]。  
![VMDQ](http://windowsitpro.com/content/content/142153/networkoptimizationvmdqsriovsml.jpg)
根据图示可以看出VMDQ将原来VMM中L2 virtual switch实现的功能通过硬件实现。  
VMM只需要进行数据复制即可使用。降低了VMM的开销，提供了吞吐能力。  

SR-IOV则更加彻底，绕过了virtual switch。通过DMA将数据直接给虚拟机使用。性能更高。

pci SR-IOV
----
Single Root I/O Virtualization  
SR-IOV解决软件模拟PCI设备效率低，直接将PCI设备直通又有扩展性问题（一个server上可以插的PCI卡数有限）。  
通过硬件方式实现了PCI设备的虚拟化。    
#### SR-IOV 中的两种新功能类型是：  

+ 物理功能 (Physical Function, PF)  
用于支持 SR-IOV 功能的 PCI 功能，如 SR-IOV 规范中定义。PF 包含 SR-IOV 功能结构，用于管理 SR-IOV 功能。PF 是全功能的 PCIe 功能，可以像其他任何 PCIe 设备一样进行发现、管理和处理。PF 拥有完全配置资源，可以用于配置或控制 PCIe 设备。

+ 虚拟功能 (Virtual Function, VF)  
与物理功能关联的一种功能。VF 是一种轻量级 PCIe 功能，可以与物理功能以及与同一物理功能关联的其他 VF 共享一个或多个物理资源。VF 仅允许拥有用于其自身行为的配置资源。

#### 优点
  - 性能－从虚拟机环境直接访问硬件。
  - 成本降低－节省的资本和运营开销包括：
    + 节能
    + 减少了适配器数量
    + 简化了布线
    + 减少了交换机端口

#### 缺点
  + 需要硬件支持（CPU，主板，网卡，OS）
  + 影响虚拟机迁移功能  

#### 使用(以intel 82576网卡为例）  
  - bios打开vt-d
  - kernel启动参数(仅intel cpu需要)增加”intel_iommu=on"
  - 删除igb模块（modprobe -r igb)
  - 设置VF个数(modprobe igb max_vfs=2)
  - 可以看到有VF设备产生  
  ```02:10.0 Ethernet controller: Intel Corporation 82576 Virtual Function (rev 01)```
  - 使用VF设备进行PCI直通或者虚拟网卡  
  


[应用场景]:https://lists.linux-foundation.org/pipermail/hotplug_sig/2005-August/001202.html
[1]:http://docs.fedoraproject.org/en-US/Fedora/13/html/Virtualization_Guide/chap-Virtualization-PCI_passthrough.html
[2]:http://www.redhat.com/archives/libvir-list/2013-March/msg00514.html
[3]:http://windowsitpro.com/virtualization/q-are-vmdq-and-sr-iov-performing-same-function
[4]:http://www.intel.cn/content/www/cn/zh/virtualization/vmdq-technology-paper.html
