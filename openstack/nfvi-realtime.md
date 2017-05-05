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
    
### 使用方法
为了达到最优的效果，需要配合使用之前的numa亲和特性、dedicated cpu pinning特性、huge page特性。<br>
由于开启实时是有代价的，一般来说，需要通过host aggregate将支持实时和不支持实时的computes host分开。<br>

+ flavor中增加“hw:cpu_realtime=yes|no"开启实时策略
  + 前提是配置了”hw:cpu_policy"为"dedicated"。
  + kvm主要做了配置：1. QEMU和guest RAM lock 2. 所有的vCPUs使用固定的实时调度策略。
+ flavor中增加hw:cpu_realtime_mask=^0-1参数控制emulator使用的cpu
  + 这个必须配置的。
  + 将某些vCPUs分配给emulator使用，且使用非实时调度策略。其他的vCPU会使用实时调度策略。（默认虚拟机会使用所有vCPU给emulator用）。
  + 更进一步的在主机上固定一些pCPU供emulator使用，在P版本才完成[URL](https://blueprints.launchpad.net/nova/+spec/libvirt-emulator-threads-policy)。

### 例子

```
openstack flavor create --ram 1024 --vcpu 4 --disk 1 realtime4
openstack flavor set --property hw:cpu_realtime=yes realtime4
openstack flavor set --property hw:cpu_policy=dedicated realtime4
openstack flavor set --property hw:cpu_realtime_mask=^0-1  realtime4
openstack server create --flavor realtime4  --image  cirros-0.3.4-x86_64-uec realtime4


[stack@localhost devstack]$ sudo virsh list
 Id    Name                           State
----------------------------------------------------
 3     instance-00000003              running

[stack@localhost devstack]$ sudo virsh show 3
error: unknown command: 'show'
[stack@localhost devstack]$ sudo virsh dumpxml  3
<domain type='kvm' id='3'>
  <name>instance-00000003</name>
  <uuid>bcd4164b-f0da-4f70-8864-6514ff5c1c54</uuid>
  <metadata>
    <nova:instance xmlns:nova="http://openstack.org/xmlns/libvirt/nova/1.0">
      <nova:package version="15.0.4"/>
      <nova:name>realtime4</nova:name>
      <nova:creationTime>2017-05-05 09:14:48</nova:creationTime>
      <nova:flavor name="realtime4">
        <nova:memory>1024</nova:memory>
        <nova:disk>1</nova:disk>
        <nova:swap>0</nova:swap>
        <nova:ephemeral>0</nova:ephemeral>
        <nova:vcpus>4</nova:vcpus>
      </nova:flavor>
      <nova:owner>
        <nova:user uuid="2a925cf044ec4d8daace6d716c114e2b">admin</nova:user>
        <nova:project uuid="2d1d6c8084544f09a3e78b0a5f5ab323">admin</nova:project>
      </nova:owner>
      <nova:root type="image" uuid="fc7db502-c469-4617-85cc-13c7cc05c0ce"/>
    </nova:instance>
  </metadata>
  <memory unit='KiB'>1048576</memory>
  <currentMemory unit='KiB'>1048576</currentMemory>
  <memoryBacking>
    <nosharepages/>
    <locked/>
  </memoryBacking>
  <vcpu placement='static'>4</vcpu>
  <cputune>
    <shares>4096</shares>
    <vcpupin vcpu='0' cpuset='0'/>
    <vcpupin vcpu='1' cpuset='1'/>
    <vcpupin vcpu='2' cpuset='2'/>
    <vcpupin vcpu='3' cpuset='3'/>
    <emulatorpin cpuset='0-1'/>
    <vcpusched vcpus='2-3' scheduler='fifo' priority='1'/>
  </cputune>
  <numatune>
    <memory mode='strict' nodeset='0'/>
    <memnode cellid='0' mode='strict' nodeset='0'/>
  </numatune>
  <resource>
    <partition>/machine</partition>
  </resource>
  <sysinfo type='smbios'>
    <system>
      <entry name='manufacturer'>OpenStack Foundation</entry>
      <entry name='product'>OpenStack Nova</entry>
      <entry name='version'>15.0.4</entry>
      <entry name='serial'>187ec700-6ff3-4e83-87b2-9559c4406874</entry>
      <entry name='uuid'>bcd4164b-f0da-4f70-8864-6514ff5c1c54</entry>
      <entry name='family'>Virtual Machine</entry>
    </system>
  </sysinfo>
  <os>
    <type arch='x86_64' machine='pc-i440fx-2.7'>hvm</type>
    <kernel>/opt/stack/data/nova/instances/bcd4164b-f0da-4f70-8864-6514ff5c1c54/kernel</kernel>
    <initrd>/opt/stack/data/nova/instances/bcd4164b-f0da-4f70-8864-6514ff5c1c54/ramdisk</initrd>
    <cmdline>root=/dev/vda console=tty0 console=ttyS0</cmdline>
    <boot dev='hd'/>
    <smbios mode='sysinfo'/>
  </os>
  <features>
    <acpi/>
    <apic/>
  </features>
  <cpu>
    <topology sockets='2' cores='1' threads='2'/>
    <numa>
      <cell id='0' cpus='0-3' memory='1048576' unit='KiB'/>
    </numa>
  </cpu>
  <clock offset='utc'>
    <timer name='pit' tickpolicy='delay'/>
    <timer name='rtc' tickpolicy='catchup'/>
    <timer name='hpet' present='no'/>
  </clock>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>destroy</on_crash>
  <devices>
    <emulator>/usr/bin/qemu-kvm</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2' cache='none'/>
      <source file='/opt/stack/data/nova/instances/bcd4164b-f0da-4f70-8864-6514ff5c1c54/disk'/>
      <backingStore type='file' index='1'>
        <format type='raw'/>
        <source file='/opt/stack/data/nova/instances/_base/85c8d3de1cae1e1b02f19d8a745fb3a132aeb055'/>
        <backingStore/>
      </backingStore>
      <target dev='vda' bus='virtio'/>
      <alias name='virtio-disk0'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x0'/>
    </disk>
    <controller type='usb' index='0' model='piix3-uhci'>
      <alias name='usb'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x2'/>
    </controller>
    <controller type='pci' index='0' model='pci-root'>
      <alias name='pci.0'/>
    </controller>
    <interface type='bridge'>
      <mac address='fa:16:3e:9b:4e:f5'/>
      <source bridge='qbr08a5bede-6a'/>
      <target dev='tap08a5bede-6a'/>
      <model type='virtio'/>
      <alias name='net0'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
    </interface>
    <serial type='pty'>
      <source path='/dev/pts/23'/>
      <log file='/opt/stack/data/nova/instances/bcd4164b-f0da-4f70-8864-6514ff5c1c54/console.log' append='off'/>
      <target port='0'/>
      <alias name='serial0'/>
    </serial>
    <console type='pty' tty='/dev/pts/23'>
      <source path='/dev/pts/23'/>
      <log file='/opt/stack/data/nova/instances/bcd4164b-f0da-4f70-8864-6514ff5c1c54/console.log' append='off'/>
      <target type='serial' port='0'/>
      <alias name='serial0'/>
    </console>
    <input type='mouse' bus='ps2'>
      <alias name='input0'/>
    </input>
    <input type='keyboard' bus='ps2'>
      <alias name='input1'/>
    </input>
    <graphics type='vnc' port='5900' autoport='yes' listen='127.0.0.1' keymap='en-us'>
      <listen type='address' address='127.0.0.1'/>
    </graphics>
    <video>
      <model type='cirrus' vram='16384' heads='1' primary='yes'/>
      <alias name='video0'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0'/>
    </video>
    <memballoon model='virtio'>
      <stats period='10'/>
      <alias name='balloon0'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x05' function='0x0'/>
    </memballoon>
  </devices>
  <seclabel type='dynamic' model='selinux' relabel='yes'>
    <label>system_u:system_r:svirt_t:s0:c687,c779</label>
    <imagelabel>system_u:object_r:svirt_image_t:s0:c687,c779</imagelabel>
  </seclabel>
  <seclabel type='dynamic' model='dac' relabel='yes'>
    <label>+107:+107</label>
    <imagelabel>+107:+107</imagelabel>
  </seclabel>
</domain>
```

### 参考
1. https://specs.openstack.org/openstack/nova-specs/specs/mitaka/implemented/libvirt-real-time.html
2. https://review.openstack.org/#/c/225893/3/specs/mitaka/approved/libvirt-emulator-threads-policy.rst
3. https://blueprints.launchpad.net/nova/+spec/libvirt-emulator-threads-policy
