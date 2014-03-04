MOM
------
### 功能  
提供KVM host上基于策略的内存overcommit管理。   
可以根据从host和guest上收集的数据调整memory overcommit配置，从而达到最优的目的。 
目前支持ballon和KSM策略控制。  

### VDSM中使用MOM的结构图  
![architecture](http://www.ovirt.org/images/b/b4/Mom-vdsm.jpg)

MOM: Memory overcommit management
