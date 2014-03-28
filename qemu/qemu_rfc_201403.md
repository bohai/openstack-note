Qemu
-----
### [RFC]VM live snapshot proposal
+ UVP的live snapshot方案。  
大致过程：
  1. pause虚拟机
  2. save device state到临时文件
  3. 做卷快照
  4. 打开dirty log和old dirty page开关[*]
  5. resume虚拟机
  6. 第一轮迭代拷贝memory到快照文件
  7. 第二轮迭代拷贝old dirty page到快照文件
  8. 合并device state的临时文件到快照文件
  9. 结束内存快照
  [*]:需要实现截获ram的写指令，并保存在dirty log中。  

+ 社区建议方案：  
  a. 利用kernel的memory截获API进行实现（内核工作还在进行中）  
  b. 利用postcopy migrate技术实现。   

https://www.mail-archive.com/kvm@vger.kernel.org/msg100029.html
### enable point-in-time snapshot exporting over NBD
支持PIT快照通过NBD暴露以及解除。

http://lists.gnu.org/archive/html/qemu-devel/2014-03/msg01345.html 

### block/json: Add JSON protocol driver
用途通过文件名指定块设备的option。
http://lists.gnu.org/archive/html/qemu-devel/2014-03/msg00192.html

其他
-----
Cache qos monitoring   
https://lwn.net/Articles/579079/
