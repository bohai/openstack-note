Huge Page
----
适合大内存/内存密集型型应用虚拟机的调优。
有利于提高查找命中。
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
内核的透明大内存页特性就是使内核发现适合启用大内存页的情景，并自动启用。实现方法是在内核中启动khugepaged 这个内核线程来收集4KB页表，一旦发现有连续分配的情况就把页表项合并。目前它的开发进度是仅能够应付2MB的大内存页。

+ Redhat系统  
通过内核参数***/sys/kernel/mm/redhat_transparent_hugepage/enabled***打开.  
+ 其他Linux系统  
通过内核参数***/sys/kernel/mm/transparent_hugepage/enabled***打开.  
