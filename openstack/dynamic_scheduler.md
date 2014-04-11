openstack动态调度现状
----
最近一个哥们在openstack邮件列表提出来做动态调度，引出很热烈的讨论。   
这里分析一下openstack动态调度功能当前的现状。  

### 实现思路
通过nova周期性任务或者独立的项目完成。    

### Gantt项目
一个刚从nova分离出来的Scheduler as a service。  
https://github.com/openstack/gantt  

### neat项目
似乎目前已经废弃，不再更新。   
http://openstack-neat.org    

###  IBM PRS项目（非开源）    
IBM PRS (Platform Resource Scheduler) 项目
http://www-01.ibm.com/common/ssi/cgi-bin/ssialias?infotype=AN&subtype=CA&htmlfid=897/ENUS213-590&appname=USN
