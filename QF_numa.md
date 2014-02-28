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

### 设置guest numa topology
qemu内部安装ACPI规范将node信息，topology信息防止在bios中供guest识别。
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

[亲和性]:http://www.ibm.com/developerworks/cn/linux/l-affinity.html
