pause/unpause:  
将虚拟机状态保存在内存中，虚拟机仍在运行，但实际上处于冻结状态。  
实际上底层调用的libvirt的suspend接口。  


suspend/unsuspend:  
将虚拟机状态/内存信息保存到磁盘。虚拟机处于stop状态。  
内存和CPU资源会被释放出来。  
一般用于维护以及不太常用的虚拟机。  
实际上底层调用的libvirt的managedSave接口。  
在这之前会卸载虚拟机的所有pci设备。  
