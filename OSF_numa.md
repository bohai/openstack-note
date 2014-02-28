### Openstack现状  
支持cpuset设定。  
不支持cpu亲和性的精细设置。  
不支持内存亲和性设置。  
不支持topology设置。  
不支持guest numa设置。  

### BP现状  
+ [vm cpu topology]  
BP状态为new(尚未成为approved），作者已经提交代码并开始review。    
实现方法：通过image的metadata设置“hw_cpu_topology”，比如:   
```
"max_sockets=1"  
"max_cores=4,max_threads=2"  
```
只是设置sockets,threads,cores等信息。不包括node信息设置。  

[vm cpu topology]:https://wiki.openstack.org/wiki/VirtDriverGuestCPUTopology
项目wiki: https://wiki.openstack.org/wiki/VirtDriverGuestCPUTopology


### 其他  
+ AutoNuma
google code上的一个项目：[vm-balancer-numa]  
主要完成cpu numa均衡放置以及重新均衡。
[vm-balancer-numa]:https://code.google.com/p/vm-balancer-numa/downloads/list
+ opennebula的[numa aware vm blance]实现
[numa aware vm blance]:http://opennebula.org/optimizing-large-numa-hypervisors-with-group-scheduling-part-1/
