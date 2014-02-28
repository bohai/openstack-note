+ 查看主机node情况  
```xml
virsh # capabilities
<topology>
      <cells num='1'>
        <cell id='0'>
          <memory unit='KiB'>8166976</memory>
          <cpus num='24'>
            <cpu id='0' socket_id='0' core_id='0' siblings='0,12'/>
            <cpu id='1' socket_id='0' core_id='1' siblings='1,13'/>
            <cpu id='2' socket_id='0' core_id='2' siblings='2,14'/>
            <cpu id='3' socket_id='0' core_id='8' siblings='3,15'/>
            <cpu id='4' socket_id='0' core_id='9' siblings='4,16'/>
            <cpu id='5' socket_id='0' core_id='10' siblings='5,17'/>
            <cpu id='6' socket_id='1' core_id='0' siblings='6,18'/>
            <cpu id='7' socket_id='1' core_id='1' siblings='7,19'/>
            <cpu id='8' socket_id='1' core_id='2' siblings='8,20'/>
            <cpu id='9' socket_id='1' core_id='8' siblings='9,21'/>
            <cpu id='10' socket_id='1' core_id='9' siblings='10,22'/>
            <cpu id='11' socket_id='1' core_id='10' siblings='11,23'/>
            <cpu id='12' socket_id='0' core_id='0' siblings='0,12'/>
            <cpu id='13' socket_id='0' core_id='1' siblings='1,13'/>
            <cpu id='14' socket_id='0' core_id='2' siblings='2,14'/>
            <cpu id='15' socket_id='0' core_id='8' siblings='3,15'/>
            <cpu id='16' socket_id='0' core_id='9' siblings='4,16'/>
            <cpu id='17' socket_id='0' core_id='10' siblings='5,17'/>
            <cpu id='18' socket_id='1' core_id='0' siblings='6,18'/>
            <cpu id='19' socket_id='1' core_id='1' siblings='7,19'/>
            <cpu id='20' socket_id='1' core_id='2' siblings='8,20'/>
            <cpu id='21' socket_id='1' core_id='8' siblings='9,21'/>
            <cpu id='22' socket_id='1' core_id='9' siblings='10,22'/>
            <cpu id='23' socket_id='1' core_id='10' siblings='11,23'/>
          </cpus>
        </cell>
      </cells>
    </topology>
```
+ 创建cpu node
```xml
<cpu>
    <topology sockets='1' cores='8' threads='1'/>
    <numa>
      <cell cpus='0-3' memory='1024000'/>
      <cell cpus='4-7' memory='1024000'/>
     </numa>
  </cpu>
```
但是从guest中并不能看到两个node。

+ VCPU绑定物理核
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
+ cputune  
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
+ memtune
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

+ 动态修改   
可以使用virsh numatune进行动态修改。  

