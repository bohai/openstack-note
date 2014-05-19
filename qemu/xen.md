xen4.4,qemu-xen-1.6编译安装

1.  下载xen源码
2.  安装依赖包（依赖包装那些，可以参考代码包的README）
3.  ./configure --enable-githttp
4.  make world
5.  make install
6. 配置内核启动  
 # grub2-mkconfig -o /boot/grub2/grub.cfg  
 # grep ^menuentry /boot/grub2/grub.cfg | cut -d "'" -f2  
 # grub2-set-default <menu entry title you want>  
7. 配置服务   
chkconfig xencommons on  
chkconfig xendomains on  
chkconfig xen-watchdog on  
8. 重启系统  
9. xl list显示成功
[root@fedora vm]# xl list
Name                                        ID   Mem VCPUs      State   Time(s)
Domain-0                                     0 40375    24     r-----     100.2
