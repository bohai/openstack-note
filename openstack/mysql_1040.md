使用glance出现以下错误：  
MySQL Server Error:Too many connections ( 1040 )   

解决办法：   
修改my.cnf，在mysqld下增加max_connections=1000。  

具体原因：   
未知  
