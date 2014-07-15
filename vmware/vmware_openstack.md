### VMware接入Openstack方案分析  
在Openstack中Nova项目中目前有两个VMware相关的Driver（ESXDriver，VCDriver）。  
从名字上可以清楚的看出来，一个是涉及ESX的Driver，一个是涉及VCenter的Driver。  
ESXDriver最早是由Citrix贡献的，VCDriver由Vmware提供。  
ESXDriver将ESX作为Hypervisor接入Openstack， VCDriver将Vcenter集群做为Hypervisor接入Openstack。  
ESXDriver方式导致的Vmware一些集群特性的丢失，VCDriver方式则解决了这些未能，当然也引入了一些新的问题（后续再说）。  
VCDriver更多的体现了Vmware与Openstack的互补，符合当前大家对混合云的共识。  

