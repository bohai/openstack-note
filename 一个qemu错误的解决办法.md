..  
声明：   
本博客欢迎转发，但请保留原作者信息!   
博客地址：http://blog.csdn.net/halcyonbaby   
新浪微博：寻觅神迹

内容系本人学习、研究和总结，如有雷同，实属荣幸！   

====================================
最近使用libvirt/qemu创建虚拟机，qemu一直报这样的一个错误：  
<pre><code>
[root@localhost centos65]# virsh create centos.xml
error: Failed to create domain from centos.xml
error: internal error: process exited while connecting to monitor: 2015-11-04T12:21:06.161304Z qemu-system-x86_64: -drive file=/home/temp/vms/centos65/centos.qcow2,if=none,id=drive-virtio-disk0,format=qcow2: could not open disk image /home/temp/vms/centos65/centos.qcow2: Could not open '/home/temp/vms/centos65/centos.qcow2': Permission denied
</code></pre>
百思不得其解，于是google之；答案不多，一般说是这种修改办法：  
修改/etc/libvirt/qemu.conf中  
<pre><code>
user="root"
group="root"
</code></pre>
然后重启libvirt。

但是怎么尝试，仍然无法解决问题，依旧报上边相同的错误。  
后来仔细排查，发现原因在与虚拟机的qcow2文件所放目录为/home/temp/vms/cento65下，由于temp这层目录的owner是temp:temp，
导致了qemu启动时访问qcow2文件失败。   

试着将qcow2文件放在/home/vms/centos65下，整个目录树owner都是root。  
创建虚拟机，成功！  
