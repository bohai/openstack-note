### mongodb性能调优

http://blog.csdn.net/gardener_db有几篇mongodb的文章非常实用。  
主要讲解了硬件选型，mongodb的cache机制。mongodb的高可靠。  

调优具体手段：  
http://java.dzone.com/articles/mongodb-performance-tuning-and  

官方调优文档：  
http://info.mongodb.com/rs/mongodb/images/MongoDB-Performance-Considerations_2.4.pdf  
写的很详细，从硬件选型、应用角度，表的设计规划，磁盘IO方面对调优进行了说明。  
http://www.mongodb.com/presentations/mongosv-2012/mongodb-performance-tuning

具体的操作手法：  
http://docs.mongodb.org/manual/reference/program/mongostat/  
http://docs.mongodb.org/manual/tutorial/evaluate-operation-performance/  
http://docs.mongodb.org/manual/core/write-performance/  

核心开发者谈调优：   
http://www.csdn.net/article/2012-11-15/2811920-mongodb-quan-gong-lue  


### 水平扩展
通过Sharding 分片进行水平扩展。   
