》coreOS&atomic： 

coreOS： 

目前最新的stable版支持到docker1.3，kernel3.17 

近期主要的更新涉及模块更新、安全patch、docker新参数支持等。 
未增加新的特性。 

目前提供的产品： 
coreOS： 
        提供了一个裁剪的支持docker的linux系统。 
        主要能力： 
                裁剪的最小化的系统 
                A、B系统无痛升级 
                支持Docker 
                集群管理能力（fleet) 
                分布式工具/服务发现（etcd） 
coreUpdate服务 
        提供了patch更新服务。管理一组服务器。 

Enterprise registry 
        提供了dockerhub的docker仓库服务。 
        https://quay.io/ 
        核心功能： 
                提供了web管理能力。 
                提供基于team的增强权限管理能力。 
                提供了完整的操作审计能力。 


atomic： 
提供了一个基于fedora剪裁的Linux系统。（未来会提供centos版） 
近期未增加新特性。 
        核心功能： 
                原子的升级回滚能力（基于ostree) 
                支持容器（基于docker） 
                提供了简单的webui，进行server管理。（基于cockpit) 
                提供编排管理能力（基于kubernetes) 
                分布式工具/服务发现（etcd） 
                


》colo FT: 
COLO - Coarse Grain Lock Stepping 
Coarse Grain Lock Stepping是粗粒度虚拟机锁步实现的FT技术。 
基于xen 的Remus FT进行实现。该技术由intel提出。 
目前在xen4.5开发中追踪，但是4.5release中并未包含该特性。 

Colo的原理： 
Colo的两个虚拟机同时运行，client会将指令发送给两个虚拟机。对比虚拟机返回的 
结果是否一致。结果一致，则继续运行；结果不一致则触发checkpoint。 

Colo目前只支持HVM的虚拟机。 
目前存在一些问题，比如稳定性。 

Intel给出了一些与Remus的性能对比资料。 
可以看出来性能与native的虚拟机基本一致。 
在web benchmark上优于remu69%，postgresql benchmark上优于remus46%。 

http://www.docin.com/p-750602866.html 
http://wiki.xenproject.org/wiki/COLO_-_Coarse_Grain_Lock_Stepping 
http://lists.xenproject.org/archives/html/xen-devel/2014-06/msg02597.html 


关联技术： 
qemu  blockcolo 
提供持续检查点的磁盘复制能力。有Fujitsu提出。 
http://wiki.qemu.org/Features/BlockReplication 



》intel migration patch 
 
主要改善有三点： 
1. 迁移线程的优先级设置，专用CPU可设置。 
2. 更新迁移时的算法，使用bytes计算downtime（之前使用页） 
3. 压缩cache释放 

根据intel的测试结果，downtime时间在500ms以内。 
patch，基于qemu1.7，未见合入社区： 
http://evaluation.s3.amazonaws.com/evals/migration_patches.tar.bz2 


》ClickOS
高性能的虚拟化中间件平台，用于快速模块化处理和分析数据包（每秒数百万的包）

优点：
1）占用空间小（运行时5MB）
2）启动速度快（30毫秒）
3）性能好（10Gb/s线速，几乎所有尺寸的PKT，45微秒的延迟）
灵活性好


用途：可用于NFV场景

》 GPU虚拟化：XenGT
XenGT是完全GPU虚拟化的解决方案。
优点：
1）性能好（GPU直通加速可达到接近native的性能）
2）功能完备（运行native图形栈来保证一致的用户视觉体验）
3）支持共享，可同时加速多个VM
弥补了直通设备（不能共享）和API转发（功能滞后）的不足。

用途：替换现有版本的GPU直通的实现，去掉当前的诸多约束。

》 mirage-os
一种构建安全和模块化的程序框架，可编译成XEN hypervisor下完全独立的单内核unikernel
优点：
1）生产系统最小化
虚拟机本身并不含有通用的操作系统，只是含有应用代码、运行环境和应用必须的OS工具等必备的，VM image文件变得更小，部署变得更快，更加易于维护。运行时可仅占数千字节
2）安全性好
a. 没有多用户操作环境，没有外壳脚本，也没有庞大的实用工具库，只有让应用程序运行起来刚好的代码，操作环境专门化，减小了外部攻击面。
b. 可构建应用为domU kernel，最大程度地减少上下文切换，同时domU的代码可用安全的语言写（非C语言）。

用途：用于构建安全、高性能的网络应用，来访问各种云、嵌入式和移动平台。
