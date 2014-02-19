CPU Qos  
-----
本质上是通过cgroup实现的。因此需要按照cgroup。

### CGroup
1. yum install libcgroup  
2. chkconfig cgconfig on  
3. service cgconfig start  
CGroup作为内核默认功能，路径为/sys/fs/cgroup/。   
使用libvirt创建虚拟机后，会产生如下目录：  
/sys/fs/cgroup/子系统名/libvirt/qemu/虚拟机domain名/

### Libvirt

```xml
<domain>
  ...
  <cputune>
    <shares>2048</shares>
    <period>1000000</period>
    <quota>1073741824</quota>
    <emulator_period>1000000</emulator_period>
    <emulator_quota>-1</emulator_quota>
  </cputune>
  ...
</domain>
```
参数            |说明                       |  
----------------|---------------------------|  
share|根据互相比值，确定虚拟机之间获取CPU的概率|
period|vcpu强制间隔的时间周期，单位微妙，范围[1000, 1000000]，每一个vcpu不能使用超过period时间周期。|
quota|vcpu最大允许带宽，单位微妙，范围[1000, 18446744073709551]。-1表示没有设置值。|
emulator_period|强制间隔的时间周期，单位微妙，范围[1000, 1000000]，虚拟机进程(qemu)不能使用超过period时间周期。|
emulator_quota|虚拟机进程(qemu)最大允许带宽，单位微妙，范围[1000, 18446744073709551]。-1表示没有设置值。|

查询Qos设置：  

```shell
# virsh schedinfo winxp
Scheduler      : posix
cpu_shares     : 2048
vcpu_period    : 1000000
vcpu_quota     : 1073741824
emulator_period: 1000000
emulator_quota : -1
```

###参考
1. vdsm中的Qos  
使用了IBM的MOM。  
http://www.linux-kvm.org/wiki/images/8/88/Kvm-forum-2013-oVirt-SLA.pdf  
MOM代码：https://github.com/aglitke/mom
