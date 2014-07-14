### 云环境下的容灾  
+ 什么是容灾？  
简单的说是对灾难的而应对策略。比如火灾，盗窃，人为损坏，火山，地震，洪水，战争，飓风等自然灾害或者人为灾害。  

+ RTO/RPO  
RPO(Recovery Point Objective): 指灾难后可能恢复到的时间点。涉及丢失业务数据的多少。  
RTO(Recovery Point Time): 指灾难发生后，业务恢复所需的时间。  
![architecture](http://redhatstackblog.files.wordpress.com/2013/11/recovery-point-objective-and-recover-time-objective.png)  

+ 容灾的分类  
按RTO时间分：cold, warm, hot  
按业务数据同步技术：基于主机复制，基于阵列复制，基于存储网络，基于虚拟机内代理，基于应用本身能力（如数据库复制能力）  
