### 云环境下的容灾  
+ 什么是容灾？  
简单的说是对灾难的而应对策略。比如火灾，盗窃，人为损坏，火山，地震，洪水，战争，飓风等自然灾害或者人为灾害。  

+ RTO/RPO  
RPO(Recovery Point Objective): 指灾难后可能恢复到的时间点。涉及丢失业务数据的多少。  
RTO(Recovery Point Time): 指灾难发生后，业务恢复所需的时间。  
![architecture](http://redhatstackblog.files.wordpress.com/2013/11/recovery-point-objective-and-recover-time-objective.png)  

+ 容灾的分类  
按RTO分：cold, warm, standby   
按RPO分：同步同步，异步同步，离线同步  
按业务数据同步技术：基于主机复制，基于阵列复制，基于存储网络，基于虚拟机内代理，基于应用本身能力（如数据库复制能力） 

+ HA与容灾的区别   
HA主要处理单组件的故障，DR则是应对大规模的故障。   
也有一些从网络视角区分两者的，LAN尺度的认为是HA的范畴，WAN尺度的任务是DR的范围。  
从云的角度看，HA是一个云环境内保障业务持续性的机制。DR是多个云环境间保障业务持续性的机制。  

### AWS容灾方案  
AWS的方案从用户场景看有如下几类：  
+ cold  
是三种方案中费用最低，RTO最长(>1 day)的方案。  
使用S3做数据备份，灾难发生时，重新申请虚拟机，利用备份数据恢复。  
数据备份可以使用普通的http, vpn, aws directconnect等链接，快照/备份技术进行业务数据的同步。  
![cold1](http://cdn.blog.celingest.com/wp-content/uploads/2013/03/AwsBackupRestore1-512x281.png)
![cold2](http://cdn.blog.celingest.com/wp-content/uploads/2013/03/AwsBackupRestore2-512x380.png)
+ pilot light   
相对经济的一种容灾方案，RTO时间(<4hrs)一般。  
使用replicate/mirror方式进行业务数据同步。  
容灾端虚拟机在灾难发生后启动。  
![pilot light1](http://cdn.blog.celingest.com/wp-content/uploads/2013/03/AwsPilotLightOff-512x336.png)
![pilot light2](http://cdn.blog.celingest.com/wp-content/uploads/2013/03/AwsPilotLightOn-512x326.png)
+ standby   
相对较贵的一种容灾方案，RTO时间(<1hrs)最好。  
使用replicate/mirror方式进行业务数据同步。  
容灾端虚拟机一直运行中，但是不提供服务。  
这种方案分两类，一类是容灾端虚拟机与生产端虚拟机等量，切换后所能提供的业务容量相同。另一种是容灾端保持较小的容量，切换后能提供业务能力但是业务容量较小，需要再进行扩展。
![standby1](http://cdn.blog.celingest.com/wp-content/uploads/2013/03/FullyWorkingLCStandby-Normal-512x326.png)
![standby2](http://cdn.blog.celingest.com/wp-content/uploads/2013/03/FullyWorkingLCStandbyFaultyLOW-512x326.png)
![standby3](http://cdn.blog.celingest.com/wp-content/uploads/2013/03/FullyWorkingLCStandbyFaultyFULL-512x326.png)

### Openstack容灾    
+ 整体架构  
Openstack的DR整体架构如下图。  
至于是否会是一个新的项目，目前并没有规划。目前主要关注于在nova/cinder/补齐功能，编排主要通过heat实现。   
后续可能成为一个独立项目甚至独立与openstack的项目。  
![openstack_dr_arch](https://wiki.openstack.org/wiki/File:DR.png)
+ 功能   
fail over(灾难后切换备节点）  
fail back(主站点故障恢复后切换会主站点）  
test(容灾演练)  
+ 方案介绍   
目前没有详细的方案。只有一个hight level的设计。   
现在还在gap识别，补齐阶段。  
+ 现状   
目前主要集中在用例分析、整体框架设计阶段。   
具体的实现主要集中在cinder侧元数据、业务数据同步相关。但是进展不乐观。   






