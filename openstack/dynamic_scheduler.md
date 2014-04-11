openstack动态调度现状
----
最近一个哥们在openstack邮件列表提出来做动态调度，引出很热烈的讨论。   
这里分析一下openstack动态调度功能当前的现状。  
目前openstack并未提供DRS、DPM的功能。  

#### 实现思路
通过nova周期性任务或者独立的项目完成。 
社区更倾向于通过单独的项目完成。  
原因主要基于两点：  
1. 实现比较复杂  
2. nova负责的计算资源管理，动态调度不应该放在nova中。  
（类似于linux设计思想中的机制和策略）  

#### Gantt项目
一个刚从nova分离出来的Scheduler as a service。  
目前仍是初始阶段，尚未真正开始，至少juno版本仍无法使用。  
初步目标仍是初始放置，未来也许有可能将动态放置放进来。  
https://github.com/openstack/gantt  

#### neat项目
似乎目前已经废弃，不再更新。   
http://openstack-neat.org    
Apache2.0 licence，部分代码使用了专利技术。  
商业使用必须获得专利许可。  

####  IBM PRS项目（非开源）    
IBM PRS (Platform Resource Scheduler) 项目  
http://www-01.ibm.com/common/ssi/cgi-bin/ssialias?infotype=AN&subtype=CA&htmlfid=897/ENUS213-590&appname=USN
