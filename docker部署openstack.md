声明：  
本人阅读笔记，翻译类文章仅作意译。如有不对之处，请指出。  
需要更本源的理解，请自行阅读英文。  

本博客欢迎转发，但请保留原作者信息!  
博客地址：http://blog.csdn.net/halcyonbaby  
新浪微博：寻觅神迹  

内容系本人学习、研究和总结，如有雷同，实属荣幸！
#  基于docker、kubernetes部署openstack到atomic系统上
openstack的服务定义，是不是看起来很简洁？
<img src="https://allthingsopendotcom.files.wordpress.com/2014/10/screen-shot-2014-10-22-at-8-39-48-am.png" width = "600" height = "400" alt="beautry" />  
openstack的实际组件构成，是不是看起来很复杂？
<img src="https://allthingsopendotcom.files.wordpress.com/2014/10/screen-shot-2014-10-22-at-8-42-30-am.png" width = "600" height = "400" alt="real" />  
所有的openstack服务彼此依赖，带来了服务生命周期管理的复杂性和低效。

比如openstack的鉴权服务keystone，在已有环境上部署一个新的keystone是否会对其他服务带来兼容性问题
是很难判断的。用现在的工具，也是难以进行回退的。
事实上，并非只有openstack是这样的，很多基础设施平台或者应用平台都有类似的问题。 

### openstack生命周期管理的方式  
主要分为两类：基于包、基于image  

+ 基于包  
通常使用PXE，并搭配puppet、chef、Ansilbe这样的配置工具。基于包的方式是低效的，原因如下：  
    + 操作系统、物理节点的差异性  
    + 合布时服务间的冲突（ports，文件系统等）  
    + 安装速度（大规模部署时，通过网络下载包安装）  
也许有人会提虚拟机+包的方式，但是：
    + 虚拟机比较重（内存、CPU、磁盘占用。启动速度）  
    + 虚拟机缺乏metadata注入手段（或者需要额外的组件和代理完成这个事情）  
    
+ 基于image  
解决了安装速度慢的问题，通常会有仓库存放image，直接下载到物理硬件上。    
但是，由于image很大，基于image的方式，增量更新仍然很缓慢。  
另外，基于iamge的方式并未解决opesntack服务间的复杂性问题。只是将问题提前到构建镜像时。  

除此之外，运维人员还会希望这个openstack生命周期管理系统，能够跨bare metal、IaaS、甚至PaaS。

### Atomic、Docker、Kubernetes带来了什么  
如果有一个openstack服务的生命周期管理方案能带来以下优点：  

+ 隔离、轻量、便携、可分离  
+ 运行态的服务关系易于描述  
+ 易于运行、易于更新  
+ 独立于openstack之外管理服务的生命周期  

这正是docker、atomic、kubernetes组合方案所能提供的。  
<img src="https://allthingsopendotcom.files.wordpress.com/2014/10/screen-shot-2014-10-22-at-10-32-57-am.png" width = "600" height = "300" alt="docker" />   

Docker提供了对linux容器的抽象，并提供了一种镜像格式。通过这种镜像格式，可以方便的分享并提供镜像间的层次关系。另外docker还提供了docker仓库来分享docker镜像。
这种方式很重要，因为开发者可以发布便携的容器镜像，维护人员将之部署在不同的平台。  
<img src="https://allthingsopendotcom.files.wordpress.com/2014/10/screen-shot-2014-10-22-at-10-34-25-am.png" width = "600" height = "300" alt="kubernetes" />    
kubernetes是开源的容器集群管理平台。它使用master/minion结构提供给了容器的调度能力。开发者可以使用声明式语法描述容器间关系，并让集群管理进行调度。
<img src="https://allthingsopendotcom.files.wordpress.com/2014/10/screen-shot-2014-10-22-at-10-35-39-am.png" width = "600" height = "300" alt="atomic" />  
Atomic项目提供给了一个安全、稳定、高性能的容器运行环境。Atomic包含了kubernetes和docker，并运行用户使用新的软件更新机制ostree。
<img src="https://allthingsopendotcom.files.wordpress.com/2014/10/screen-shot-2014-10-23-at-2-20-49-pm.png" width = "600" height = "300" alt="atomic" />   
将以上三者结合起来的方案就像上图。openstack开发者使用自己熟悉的环境进行开发（linux/vagrant/libvirt),然后向仓库提交服务镜像。运维人员将kubernetes配置导入生命周期管理工具，然后启动pods和services。容器镜像会被下载到本地并部署这些openstack服务。由于服务是隔离的，我们可以在单台机器上最大化密度地部署openstack服务。除此之外还有其他优点，比如回滚、部署、更新的速度等。

原文地址：   
http://allthingsopen.com/2014/10/22/a-demonstration-of-kolla-docker-and-kubernetes-based-deployment-of-openstack-services-on-atomic/








