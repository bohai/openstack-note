### RDM（raw device mapping）


### libvirt xml
第一种为推荐方式，可以实现LUN隔离。
```xml
     <disk type='block' device='lun'>
       <driver name='qemu' type='raw' cache='none'/>
       <source dev='/dev/mapper/360022a110000ecba5db427db00000023'/>
       <target dev='sdb' bus='scsi'/>
       <address type='drive' controller='0' bus='0'/>
     </disk>

     <disk type='block' device='disk'>
       <driver name='qemu' type='raw' cache='none'/>
       <source dev='/dev/mapper/360022a110000ecba5db4074800000022'/>
       <target dev='sda' bus='scsi'/>
       <address type='drive' controller='0' bus='1'/>
     </disk>

     <controller type='scsi' index='0' model='virtio-scsi'/>
```
### qemu命令




