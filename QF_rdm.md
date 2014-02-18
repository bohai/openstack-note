### RDM（raw device mapping）
-----
使用的virtio-scsi。目前主推的方式。在可扩展性，灵活性，可伸缩性上好于virtio-blk。
适用于IO密集型应用的场景。
#####libvirt xml
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
##### qemu命令
+ disk方式的RDM
```xml
-drive file=/dev/sdb,if=none,id=drive-scsi0-0-0-1,format=raw,cache=none 
-device scsi-hd,bus=scsi0.0,channel=0,scsi-id=0,lun=1,drive=drive-scsi0-0-0-1,id=scsi0-0-0-1 
-device virtio-scsi-pci,id=scsi0,bus=pci.0,addr=0x4
```
+ lun方式的RDM

###virtio-blk
-----
这个同RDM比较容易混淆,这个是用的virtio-blk。（不推荐使用）
#####libvirt xml
```xml
 <disk type='block' device='lun'>
       <driver name='qemu' type='raw' cache='none'/>
       <source dev='/dev/mapper/360022a110000ecba5db427db00000023'/>
       <target dev='vdb' bus='virtio'/>
       <address type='pci' domain='0x0000' bus='0x00' slot='0x06' function='0x0'/>
 </disk>
```
#####qemu命令
```xml
-drive file=/dev/sdb,if=none,id=drive-virtio-disk1,format=raw,cache=none 
-device virtio-blk-pci,scsi=off,bus=pci.0,addr=0x6,drive=drive-virtio-disk1,id=virtio-disk1
```

###参考：  
http://www.ovirt.org/Features/Virtio-SCSI
