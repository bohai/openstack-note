### openstack特性之虚拟机实时性
虚拟机实时性特性是openstack M版本引入的。<br>
虚拟机实时性特性，旨在改善提供低延迟的CPU调度能力。<br>

实时性虚拟机主要用于跑需要对CPU执行延迟要求苛刻的负载。典型的如NFV场景的应用，也可以用于金融市场高频交易等场合。<br>

### 原理
目前主要有以下手段改善实时性：
+ CPU pinning<br>
  防止虚拟机之间互相“steal time”，从而影响CPU调度延迟。<br>
+ 主机资源<br>
  解决kernel task占用CPU，导致的CPU调度延迟。<br>
+ QEMU Emulator thread pin<br>
  解决QEMU Emulator线程占用CPU，导致的CPU调度延迟。<br>
+ Guest VCPU调度策略<br>
  给guest vCPUs配置合适的调度策略，解决调度导致的CPU延迟。<br>
+ 使用大页<br>
  确保Guest内存不会被swap到host上。<br>
+ 防止QEMU内存swap<br>
  配置QEMU内存不被swap，避免内存swap导致的延迟。<br>
  
### 使用注意
实时性是存在代价的。为了在最坏情况下，满足对CPU延迟的苛刻要求，整个系统的吞吐能力都要做妥协。<br>
因此，无条件使用实时性，并不合理。只有在业务负载真的需要时，才开启这个选项。<br>
很多情况下，仅仅使用CPU pinning就可以满足业务的对实时性的 要求。<br>

根据社区的测试效果：
  + baremetal + dedicated cpu + non-realtime scheduler<br>
    worst case latency：150微秒，mean latency：2微秒<br>
  + KVM + dedicated cpu + realtime scheduler<br>
    worst case latency：14微秒， mean latency：<10微秒 <br>

### 例子


### 参考
1. https://specs.openstack.org/openstack/nova-specs/specs/mitaka/implemented/libvirt-real-time.html
2. https://review.openstack.org/#/c/225893/3/specs/mitaka/approved/libvirt-emulator-threads-policy.rst
3. https://blueprints.launchpad.net/nova/+spec/libvirt-emulator-threads-policy
