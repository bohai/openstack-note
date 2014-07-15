### VMware接入Openstack方案分析  
在Openstack中Nova项目中目前有两个VMware相关的Driver（ESXDriver，VCDriver）。  
从名字上可以清楚的看出来，一个是涉及ESX的Driver，一个是涉及VCenter的Driver。  
ESXDriver最早是由Citrix贡献的，VCDriver由Vmware提供。  
ESXDriver将ESX作为Hypervisor接入Openstack， VCDriver将Vcenter集群做为Hypervisor接入Openstack。  
ESXDriver方式导致的Vmware一些集群特性的丢失，VCDriver方式则解决了这些未能，当然也引入了一些新的问题（后续再说）。  
VCDriver更多的体现了Vmware与Openstack的互补，一方面是VMware现有的存量很大，而且很多企业应用并非按照云的思想开发；另一方面新的应用多以云的思想开发。这也符合当前各厂商对混合云趋势的共识。  

### ESXDriver    
ESXDriver与其他Hypervisor的接入方式略有差别。  
主要有以下缺点：  
与KVM等不同，VM跑在ESXi上，并非nova-compute所在节点。  
ESXDriver限制，每个nova-compute服务仅支持一台ESXi主机。    
不支持VCenter上高级特性，比如DRS。   
![ESXDriver](http://openstack-huawei.github.io/images/blog/openstack-vsphere/image007.png)
![nova_ESX](http://openstack-huawei.github.io/images/blog/openstack-vsphere/image009.png)
### VCDriver 
+ 介绍
本文主要介绍VCDriver方式接入。这种方式将集群作为Hypervisor接入，自然就拥有了HA，DRS，VMotion能力。      
目前每个compute节点只能同时支持一种hypervisor。
Grizzly每个compute服务只能支持一个VCenter集群，Havana版本已经去除了这个限制。  
VCDriver中每个cluster都要有一个Datastore进行配置和使用。  
由于cluster作为一个hypervisor整体呈现，也带来了资源跨ESXi节点的问题，具体来说就是作为Hypervisor整体呈现的CPU、内存资源很充足，但是创建虚拟机是发现任何一个节点的资源都不满足虚拟机需要的情况。    
+ 接入图示  
![VCDriver](http://openstack-huawei.github.io/images/blog/openstack-vsphere/image011.png)
![VCD_arch](http://varchitectthoughts.files.wordpress.com/2013/06/vsphere-with-nova-arch.jpeg)
+ 接入方法  
nova.conf文件的配置：（可以看到指定了cluseter c1接入）  
```xml
[DEFAULT]  
compute_driver = vmwareapi.VMwareVCDriver  
[vmware]  
host_password = Huawei-123  
host_username = Administrator@vsphere.local  
host_ip = 186.100.21.221  
#datastore_regex = NOT DEFINED  
cluster_name = c1            #可以支持配置多个cluster   
```
