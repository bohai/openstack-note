### KernelCare
CloudLinux的KernelCare：更新kernel patch而无需重启。（支持CentOS 6, RHEL 6, CloudLinux OS 6 and OpenVZ (64-bit only).） 
KernelCare是基于开源代码（Linux kernel mode的）和私有代码组合而成。后续可能开源。  

另一个更新的工具是Kpatch，目前仍在开发中。  

RHEL有类似的服务（Ksplice services），Oracle也有类似的服务。  
### Kpatch
开发中，尚不可以用于生产环境。  
Kpatch更新的对象以函数为级别。  

Kpatch主要有四个组件。  
1. kpatch-build     
产生hot patch。 通过对比包含patch和不包含patch的kernel差异，产生hotpatch。  
  
2. hot patch module  
内核模块文件：包含替换函数和源函数的元数据。  
  
3. kpatch core module  
内核模块文件，提供注册新函数的功能。利用内核kernel ftrace subsystem通过钩子将原函数进行重定向。  
  
4. kpatch utility  
管理热patch。可以配置在启动时加载哪些patch。这样相同的内核即使重启，仍然包含所打的热patch。  

### 如何使用kpatch进行热patch
目前支持Fedora20，RHEL7，Ubuntu14.04，Debian8.0，Debian7.*  
详细使用过程见https://github.com/dynup/kpatch  
  
限制：  
1. 某些函数不支持hot patch，如（schedule(), sys_poll(), sys_select(), sys_read(), sys_nanosleep()）  
2. 初始化函数不支持hot patch,如__init  
3. 不支持修改静态分配的数据  
4. 不支持vdso中的函数进行patch  
5. kpatch和ftrace以及kprobes存在不兼容  
6.  改变函数与动态分配数据间的交互的patch可能存在安全性问题。  
  
### 不重启更新kernel （RHEL/Centos)  
# uname -r   
2.6.32-71.29.1.el6.i686  
Ok, we have to patch:
# yum update kernel*
Grab the kexec tools:
# yum install kexec-tools
Now we get last installed kernel version release and put it on a var:
# latestkernel=`ls -t /boot/vmlinuz-* | sed "s/\/boot\/vmlinuz-//g" | head -n1` 

# echo $latestkernel 
2.6.32-220.4.1.el6.i686
Now we need to load the new kernel version in memory:
# kexec -l /boot/vmlinuz-${latestkernel} --initrd=/boot/initramfs-${latestkernel}.img --append="`cat /proc/cmdline`"
Finally, we can issue a reset:
# kexec -e
..and.. wow, we lost the system! ..Well, not exactly.
The system will “restart without restarting”..something like a fast reboot, without performing BIOS checks (and you know how long can a full system restart last).
这步terminal console会断掉，即socket被重置了。

# uname -r
2.6.32-220.4.1.el6.i686

参考：
http://www.zdnet.com/kernelcare-new-no-reboot-linux-patching-system-7000029127/
http://korovamilky.tumblr.com/post/16460518079/running-new-linux-kernel-without-rebooting
http://rhelblog.redhat.com/2014/02/26/kpatch/
https://github.com/dynup/kpatch


