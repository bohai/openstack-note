Huge Page
----
主要提升TLB查找效率和命中率。是和大内存/内存密集型型应用虚拟机的调优。  
+ libvirt  
xml设置方法：
```xml
<memoryBacking>
	<hugepages/>
</memoryBacking>
```
+ 内核参数  
通过内核参数***/proc/sys/vm/nr_hugepages***修改。

Transparent Huge Page
----
直观理解是可以将Host Huge Page与Guest对齐，是内存的使用效率更高。  
+ Redhat系统  
通过内核参数***/sys/kernel/mm/redhat_transparent_hugepage/enabled***打开.  
+ 其他Linux系统  
通过内核参数***/sys/kernel/mm/transparent_hugepage/enabled***打开.  
