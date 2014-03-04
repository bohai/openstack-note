MOM
------
### 功能  
提供KVM host上基于策略的内存overcommit管理。   
可以根据从host和guest上收集的数据调整memory overcommit配置，从而达到最优的目的。 
目前支持ballon和KSM策略控制。  

### VDSM、MOM
架构图：  
![architecture](http://www.ovirt.org/images/b/b4/Mom-vdsm.jpg)  
交互图：  
![architecture](http://www.ovirt.org/images/e/e6/Mom-flow.png)  
VDSM和MOM在部署上互相独立存在，VDSM向MOM提供policy使用。并使用MOM的RPC API进行控制。  


MOM: Memory overcommit management
