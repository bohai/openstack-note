Huge Page
----
适合大内存/内存密集型型应用虚拟机的调优。    
大内存页的好处显而易见，免得频繁调度内存页，减少缺页异常，提高应用程序效率。缺点是稍显浪费内存。  
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
