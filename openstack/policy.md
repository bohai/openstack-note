policy
----
### 用途
user/tenants/role三个概念。  
policy简单的说是控制一个user在tenants中的权限。即user可以执行哪些操作，不能执行哪些操作。  
role是权限的集合，可以赋予某个user一个role。  
policy直观看是一个json文件，位置在/etc/[SERVICE_CODENAME]/policy.json中。  
policy.json的格式类似与dict。其中key为action，value未rule。  

policy.json会由程序读取加载，并用于用户操作的权限验证。  

### 使用
调用nova/policy.py模块中的enforce()。  
**似乎可以改进的地方**可以通过内核inotify改进。  
（该处已经确认，openstack通过文件修改时间识别文件是否修改，并重新加载）    
enforce()会导致policy.json被重新加载，也就是说修改权限不需要重启服务。  

### 代码参考
compute/api.py  
unlock()--->check_policy()----->policy.enforce()   


### 待验证
修改policy，发送API消息验证。
