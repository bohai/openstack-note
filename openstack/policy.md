policy
----
### 用途
user/tenants/role三个概念。  
policy简单的说是控制一个user在tenants中的权限。即user可以执行哪些操作，不能执行哪些操作。  
role是权限的集合，可以赋予某个user一个role。  
policy直观看是一个json文件，位置在/etc/[SERVICE_CODENAME]/policy.json中。  
policy.json的格式类似与dict。其中key为action，value未rule。  

### 
