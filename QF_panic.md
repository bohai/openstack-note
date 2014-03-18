panic设备
-----
panic设备可以让libvirt从qemu guest获取到panic通知。  

### libvirt用法
```xml
<devices>
    <panic>
      <address type='isa' iobase='0x505'/>
    </panic>
</devices>
```
大部分情况下用户无需指定address。
### qemu用法
```shell
-device pvpanic
```
### 实现原理

### openstack上应用

