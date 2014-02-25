qemu代码阅读
-----



libvirt代码阅读
-----
src/libvirt.c中定义了所有的API。    
通过插件机制执行不同hypervisor的实现。    
具体实现见插件目录，比如qemu在src/qemu下。  
