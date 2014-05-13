+ pause/unpause  
将虚拟机状态保存在内存中，虚拟机仍在运行，但实际上处于冻结状态。  
实际上底层调用的libvirt的suspend接口。  


+ suspend/resume  
将虚拟机状态/内存信息保存到磁盘。虚拟机处于stop状态。  
内存和CPU资源会被释放出来。  
一般用于维护以及不太常用的虚拟机。  
实际上底层调用的libvirt的managedSave接口。  
在这之前会卸载虚拟机的所有pci设备。  


+ lock/unlock  
设置虚拟机的lock状态，通过修改数据库中字段实现。  
lock状态的虚拟机几乎不可以做任何操作。  
通过装饰器@check_instance_lock对方法入口检查。  


+ migrate/resize    
  migrate和resize本质上都是在做冷迁移。  
  差别在于resize会指定新的flavor，migrate只是迁移位置。  
  位置依靠scheduler自动选择，目前不能手工指定。   
  只支持对active和stop状态的虚拟机操作。   
  + migrate
    
  + resize/confirmResize/revertResize   
    resize会保留原虚拟机一定时间（一般24小时），可以进行回滚操作。或者confirm操作，  
    confirm操作会删除原虚拟机。  
    resize底层使用了快照能力。  

+ rebuild/evacuate    
  两者底层实际上是一个处理函数（self.compute_rpcapi.rebuild_instance）。  
  + rebuild
    rebuild操作可以近似理解为重装系统。  
  
    内部处理大致为：Shutdown, Re-Image, and then Reboot 。   
    serverRef和IP地址保持不变。但是虚拟机中的所有注入信息和软件、配置会丢失。  
    rebuild可以重新指定image, IP, 注入信息， 密码等内容。  
    rebuild仅支持active和stopped、ERROR状态的虚拟机。  

  + evacuate
    evacuate操作用于虚拟机所在host故障，在其他节点重新启动虚拟机。  
    evacuate为上层进行HA提供基础能力。  
    evacuate对非共享存储相当于重建，对共享存储才相当于通常意义上的HA。

+ backup/createImage
  两者本质上都利用了snapshot能力。将虚拟机进行snapshot然后，传送glance上进行管理。
  + bakcup   
    bakcup只支持active和stopped状态虚拟机进行操作。  
    该接口为上层周期性备份虚拟机提供了原子能力。  
    其中backup-type指定了备份类型，rotation提供了指定备份数的能力。  
    对backup-type相同的备份，最多保留rotation个备份。会替换最旧的备份。   
  + createImage   
    可以对active，stopped，pause，suspend状态的虚拟机进行操作。  
    底层实际上也是利用snapshot的能力。   

+ diagnostic
  提供对虚拟机的磁盘读写，网络读写，cpu,内存使用等信息，用于进行故障诊断等目的。    



