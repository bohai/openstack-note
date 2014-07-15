### VMware接入Openstack方案分析  
在Openstack中Nova项目中目前有两个VMware相关的Driver（ESXDriver，VCDriver）。  
从名字上可以清楚的看出来，一个是涉及ESX的Driver，一个是涉及VCenter的Driver。  
前者最早是由Citrix贡献的，后者由Vmware提供。  
前者将ESX作为Hypervisor接入Openstack， 后者将Vcenter集群做为Hypervisor接入Openstack。  
后者弥补了前一种方式导致的Vmware一些集群特性的丢失。  

