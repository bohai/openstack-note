### Openstack现状  
不支持

### BP现状  
+ [guest numa]  
BP状态为new(尚未成为approved），作者已经提交代码并开始review。    
实现方法：通过image的metadata设置“hw_cpu_topology”，比如:   
```
"max_sockets=1"  
"max_cores=4,max_threads=2"  
```
[guest numa]:https://wiki.openstack.org/wiki/VirtDriverGuestCPUTopology

+

### 其他  
+ AutoNuma
google code上的一个项目：[vm-balancer-numa]  
主要完成cpu numa均衡放置以及重新均衡。
[vm-balancer-numa]:https://code.google.com/p/vm-balancer-numa/downloads/list
+ opennebula的[numa aware vm blance]实现
[numa aware vm blance]:http://opennebula.org/optimizing-large-numa-hypervisors-with-group-scheduling-part-1/
