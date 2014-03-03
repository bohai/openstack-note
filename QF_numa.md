Numa
-----
### 查看主机node情况  
+ 使用virsh命令查看  
```xml
virsh # capabilities
<topology>
      <cells num='1'>
        <cell id='0'>
          <memory unit='KiB'>8166976</memory>
          <cpus num='24'>
            <cpu id='0' socket_id='0' core_id='0' siblings='0,12'/>
            ...
          </cpus>
        </cell>
      </cells>
    </topology>
```
+ 使用numactl命令查看  
```xml
# numactl --hardware
```
Guest Numa
-----
### 设置guest numa topology
qemu内部安装ACPI规范将node信息，topology信息防止在bios中供guest识别。  
guest识别numa topology的意义在于，guest中的OS可以更好的进行进程调度和内存分配。  
+ libvirt
```xml
<cpu>
    <topology sockets='1' cores='8' threads='1'/>
    <numa>
      <cell cpus='0-3' memory='1024000'/>
      <cell cpus='4-7' memory='1024000'/>
     </numa>
  </cpu>
```
+ qemu
```xml
-smp 8,sockets=1,cores=4,threads=1
-numa node,nodeid=0,cpus=0-3,mem=1000 -numa node,nodeid=1,cpus=4-7,mem=1000
```
可以在guest中使用numactl --hardware看到这些node节点。  

CPU/内存[亲和性]设置
----
进程的处理器亲和性（Processor Affinity），即是CPU的绑定设置，是指将进程绑定到特定的一个或多个CPU上去执行，  
而不允许调度到其他的CPU上。  
  
在虚拟化环境中，qemu的vcpu是作为线程存在的，可以对线程进行亲和性设置。  
多数情况下，我们无需设置亲和性。但是某些特殊场合，比如需要确保CPU资源不被其他虚拟机负载影响，  
可以设置CPU的亲和性。  

CPU亲和性由libvirt通过调用sched_setaffinity系统调用实现(如下以cpu热插中的代码为例），不需要在qemu层进行设置。  
```c
src/qemu/qemu_driver.c：
static int qemuDomainHotplugVcpus(virQEMUDriverPtr driver,
        ¦       ¦       ¦       ¦ virDomainObjPtr vm,
        ¦       ¦       ¦       ¦ unsigned int nvcpus)
{
      ...
      virProcessSetAffinity(cpupids[i],
      ...
}
src/util/virprocess.c：
int virProcessSetAffinity(pid_t pid, virBitmapPtr map)
{
      ...
      if (sched_setaffinity(pid, masklen, mask) < 0) {
      ...
}
```

memory的亲和性也是由libvirt通过调用numa_set_membind函数实现（由libnuma.so提供，该so为numactl的库）。
```c
  int
  virNumaSetupMemoryPolicy(virNumaTuneDef numatune,
          ¦       ¦       ¦virBitmapPtr nodemask)
  {
        ...
        numa_set_membind(&mask);
        ...
```

备注：可以使用taskset工具手工对线程设置亲和性。

### VCPU绑定物理核
```xml
<vcpu cpuset='1-2'>4</vcpu>
```
查看CPU绑定情况（其中28863为qemu的进程IP）
```shell
#grep Cpus_allowed_list /proc/28863/task/*/status 
/proc/28863/task/28863/status:Cpus_allowed_list:    1-2
/proc/28863/task/28864/status:Cpus_allowed_list:    1-2
/proc/28863/task/28865/status:Cpus_allowed_list:    1-2
/proc/28863/task/28866/status:Cpus_allowed_list:    1-2
/proc/28863/task/28867/status:Cpus_allowed_list:    1-2
```
### cputune  
cputune提供了精细的vcpu绑定设定，可以具体到每个vcpu设置。   
而且提供vcpu能力的标准化，如quota,period,shares，可以用于实现cpu的Qos。  
```xml
 <vcpu placement='static'>4</vcpu>
  <cputune>
    <shares>2048</shares>
    <period>1000000</period>
    <quota>-1</quota>
    <vcpupin vcpu='0' cpuset='8'/>
    <vcpupin vcpu='1' cpuset='16'/>
    <emulatorpin cpuset='16'/>
  </cputune>
```
### memtune
```xml
<numatune>
    <memory mode="strict" nodeset="1"/>
  </numatune>
```
查看内存的设定情况：(其中18104为qemu的pid)
```shell
#grep Mems_allowed_list /proc/18104/task/*/status
/proc/18104/task/18104/status:Mems_allowed_list:    1
/proc/18104/task/18105/status:Mems_allowed_list:    1
/proc/18104/task/18106/status:Mems_allowed_list:    1
/proc/18104/task/18114/status:Mems_allowed_list:    1
```

### 动态修改   
+ numa  
可以使用virsh numatune进行动态修改。  
+ cpu affinity  
可以使用virsh vcpupin进行修改。
+ 设置emulator的cpu affinity  
可以使用virsh emulatorpin进行修改。

Libvirt/qemu社区关于numa的最新动态
-----
+ [Add support for binding guest numa nodes to host numa nodes]  
社区review中。  
提供了guest memory绑定策略的设置能力。    
避免某些情况下由此导致的性能下降。 （比如PCI passthrough是设备DMA传输的情况？这点还是不太懂）  
qemu配置方法范例：  
```shell
-object memory-ram,size=512M,host-nodes=1,policy=membind,id=ram-node0 
-numa node,nodeid=0,cpus=0,memdev=ram-node0 
-object memory-ram,size=1024M,host-nodes=2-3,policy=interleave,id=ram-node1 
-numa node,nodeid=1,cpus=1,memdev=ram-node1 
```


[Add support for binding guest numa nodes to host numa nodes]:https://lists.gnu.org/archive/html/qemu-devel/2013-12/msg00568.html
[亲和性]:http://www.ibm.com/developerworks/cn/linux/l-affinity.html

numa的一些缺点
------
如果配置不当，可能不但无法获取高性能，反而有可能导致性能恶化。    

另外numa与透明页共享的冲突，即由于页合并导致的跨node访问。   
vmware对此有专门优化，频繁访问的页面，在node上有页面副本，从而避免跨node访问带来的性能恶化。  

Qemu-kvm情况下，目前也有感知NUMA的KSM技术。需要通过内核参数***sysfs /sys/kernel/mm/ksm/merge_nodes***打开。   
默认全页面合并，设置为0，则只有相同node的页面才会合并。  

[专门优化]:https://pubs.vmware.com/vsphere-50/index.jsp#com.vmware.vsphere.resmgmt.doc_50/GUID-6D818472-D683-410F-84C3-0C56C21F4459.html

Vmware相关
------
Vmware支持CPU、内存的绑定,toppology的设置。  
同时支持cpu、内存在node间的迁移。以及自动的平衡、[再平衡]策略。
[再平衡]:https://pubs.vmware.com/vsphere-50/index.jsp#com.vmware.vsphere.resmgmt.doc_50/GUID-BD4A462D-5CDC-4483-968B-1DCF103C4208.html

### NUMA调优  
[NUMA调优]:https://access.redhat.com/site/documentation/en-US/Red_Hat_Enterprise_Linux/7-Beta/html-single/Virtualization_Tuning_and_Optimization_Guide/index.html
+ 使用内核AutoNuma 进行balance  
关闭自动numa
```shell
# echo NONUMA > /sys/kernel/debug/sched_features
```
查看自动numa
```shell
# cat /sys/kernel/debug/sched_features 
```
打开自动numa
```shell
# echo 1 > /sys/kernel/mm/autonuma/enabled
```

