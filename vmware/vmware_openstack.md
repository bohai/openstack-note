### VMware接入Openstack方案分析  
在Openstack中Nova项目中目前有两个VMware相关的Driver（ESXDriver，VCDriver）。  
从名字上可以清楚的看出来，一个是涉及ESX的Driver，一个是涉及VCenter的Driver。  
ESXDriver最早是由Citrix贡献的，VCDriver由Vmware提供。  
ESXDriver将ESX作为Hypervisor接入Openstack， VCDriver将Vcenter集群做为Hypervisor接入Openstack。  
ESXDriver方式导致的Vmware一些集群特性的丢失，VCDriver方式则解决了这些未能，当然也引入了一些新的问题（后续再说）。  
VCDriver更多的体现了Vmware与Openstack的互补，一方面是VMware现有的存量很大，而且很多企业应用并非按照云的思想开发；另一方面新的应用多以云的思想开发。这也符合当前各厂商对混合云趋势的共识。  

### ESXDriver  
ESXDriver与其他Hypervisor的接入方式类似。nova compute与hypervisor存在一对一的关系。  

![ESXDriver](http://openstack-huawei.github.io/images/blog/openstack-vsphere/image007.png)

### VCDriver  
本文主要介绍VCDriver方式接入。  
