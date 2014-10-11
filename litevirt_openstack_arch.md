1. 整体部署架构
fuel-master可以使用虚拟机部署，也可以使用物理机部署。  
fuel支持将openstack部署在虚拟机中（主要做体验、演示使用），也可以将openstack部署在物理机上。  
部署如图：   


litevirt_openstack软件堆栈如图：

2. 安装过程
【使用虚拟机方式部署】   
推荐体验使用。  
a. 使用litevirt-hypervisor部署一台服务器。  
b. 使用litevirt-hypervisor中的kimchi，创建fuel-master虚拟机。  
c. 使用kimchi创建若干台虚拟机作为openstack环境使用。
d. fuel-master识别出这些虚拟机。
e. 通过fuel-master创建一套openstack环境。

【使用物理机方式部署】
a. 使用fuel-master的iso部署一台服务器。
b. fuel-masters
