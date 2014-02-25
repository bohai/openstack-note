qemu代码阅读
-----
qemu monitor命令，比如savevm命令。    
1. 查看hmp-commands.hx中该命令的处理函数。   
2. 我们通过grep在savevm.c中找到do_savevm函数
hmp-commands.hx例子：  
```xml
    {
        .name       = "savevm",
        .args_type  = "name:s?",
        .params     = "[tag|id]",
        .help       = "save a VM snapshot. If no tag or id are provided, a new snapshot is created",
        .mhandler.cmd = do_savevm,
    },
```
savevm.c中的do_savevm函数
```c
  void do_savevm(Monitor *mon, const QDict *qdict)
  {
      BlockDriverState *bs, *bs1;
      QEMUSnapshotInfo sn1, *sn = &sn1, old_sn1, *old_sn = &old_sn1;
      int ret;
      QEMUFile *f;
```


libvirt代码阅读
-----
src/libvirt.c中定义了所有的API。    
通过插件机制执行不同hypervisor的实现。    
具体实现见插件目录，比如qemu在src/qemu下。  
