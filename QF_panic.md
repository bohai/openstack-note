panic设备
-----
panic设备可以让libvirt从qemu guest获取到panic通知。  

### libvirt用法
libvirt 1.2.1后支持该功能。
```xml
<devices>
    <panic>
      <address type='isa' iobase='0x505'/>
    </panic>
</devices>
```
大部分情况下用户无需指定address。
### qemu用法  
qemu 1.5以后开始支持。
```shell
-device pvpanic
```
info qtree可以看到如下设备：
```
          dev: pvpanic, id ""
            ioport = 1285
```
### 实现原理

### openstack上应用

