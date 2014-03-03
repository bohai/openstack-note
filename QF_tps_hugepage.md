Huge Page
----
+ libvirt  
xml设置方法：
```xml
<memoryBacking>
	<hugepages/>
</memoryBacking>
```

Transparent Huge Page
----
+ Redhat系统  
通过内核参数***/sys/kernel/mm/redhat_transparent_hugepage/enabled***打开.  
+ 其他Linux系统  
通过内核参数***/sys/kernel/mm/transparent_hugepage/enabled***打开.  
