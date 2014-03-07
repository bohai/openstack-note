+ qemu-img支持预占空间，通过参数“preallocation=full”  
http://lists.gnu.org/archive/html/qemu-devel/2014-02/msg01754.html

+ SSD deduplication(开发中）  
在qcow2中提供block level的去重  

+ Quorum block driver（社区review中）  
提供类似raid的机制保护虚拟机。会写三份以上数据。读数据时会进行投票，判断是否最新版本的数据。  

+ Basis of the block filter infrastructure  
提供类似于kernel device mapper的机制。使用例子如：luks加密 block driver。  

+ Block [throttling] infrastructure  
提供对用户进行IO管理的能力。支持 bursting。    
例子（burst为10000iops）：  

>qemu -enable-kvm -drive file=debian.raw,iops=75,iops_max=10000,if=virtio,cache=none

+ [RFC] platform device passthrough  
Guest OS直接访问host设备得MMIO,DMA regions,以及接受host设备的中断。  
http://lists.gnu.org/archive/html/qemu-devel/2014-02/msg04666.html

+ 支持Intel MPX (Memory Protection Extensions)   
支持Intel MPX特性（一种硬件辅助技术，目的在于加强指针使用安全性。  
http://lists.gnu.org/archive/html/qemu-devel/2014-02/msg04263.html

+ [RFC PATCH] block: optimize zero writes with	bdrv_write_zer
自动使用bdrv_write_zeroes对快设备写0请求进行优化。  
http://lists.gnu.org/archive/html/qemu-devel/2014-02/msg04134.html  

+ Add support for binding guest numa	nodes  
http://lists.gnu.org/archive/html/qemu-devel/2014-02/msg03289.html
社区review中。
提供了guest memory绑定策略的设置能力。
避免某些情况下由此导致的性能下降。 （比如PCI passthrough是设备DMA传输的情况？这点还是不太懂）
qemu配置方法范例：
```shell
-object memory-ram,size=512M,host-nodes=1,policy=membind,id=ram-node0 
-numa node,nodeid=0,cpus=0,memdev=ram-node0 
-object memory-ram,size=1024M,host-nodes=2-3,policy=interleave,id=ram-node1 
-numa node,nodeid=1,cpus=1,memdev=ram-node1 
```

+ [RFC PATCH v2 00/12] mc: fault tolerante through	micro-chec
http://lists.gnu.org/archive/html/qemu-devel/2014-02/msg03042.html  



[throttling]:http://www.nodalink.com/blog_throttling_25_01_2014.html
[qemu timer]:http://lists.gnu.org/archive/html/qemu-devel/2014-02/msg04177.html
