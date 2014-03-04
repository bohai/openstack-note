MOM
------
MOM: Memory overcommit management   
最初由IBM一名员工开发并在IBM项目中使用。目前ovirt项目也引入了该组件。     
https://github.com/oVirt/mom  
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


### MOM内部  
基于policy和收集的数据对memory overcommit进行控制。  
![architecture](http://www.ibm.com/developerworks/cn/linux/l-overcommit-kvm-resources/figure2.gif)

  
其中各组件：  
controller：基于底层接口提供调控能力，比如触发ballon调整,ksm扫描合并。  
evaluator：基于collector的数据和policy，判断是否要触发管理动作。  
Policy：策略定义。定义何时应该触发管理动作执行。  
collector：负责收集各种数据。  


