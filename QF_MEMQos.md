Mem Qos
-----
### libvirt  
xml配置：  
```xml
<memtune>
<hard_limit unit='KiB'>4194304</hard_limit>
<soft_limit unit='KiB'>8388608</soft_limit>
<min_guarantee unit='Kib'>1024000</min_guarantee>>
<swap_hard_limit unit='KiB'>4194304</swap_hard_limit>
</memtune>
```

命令设置：  
```shell
memtune <domain> [--hard-limit <number>] [--soft-limit <number>] [--swap-hard-limit <number>] [--min-guarantee <number>] [--config] [--live] [--current]
```

参数|说明|
----|----|
hard_limit|强制最大内存|
soft_limit|最大可用内存|
min_guarantee|最小保证内存|
swap_hard_limit|swap强制最大内存|
