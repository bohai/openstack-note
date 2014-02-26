###before 20140215
+ qemu-img支持预占空间，通过参数“preallocation=full”  
http://lists.gnu.org/archive/html/qemu-devel/2014-02/msg01754.html

###after 20140215
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


[throttling]:http://www.nodalink.com/blog_throttling_25_01_2014.html
