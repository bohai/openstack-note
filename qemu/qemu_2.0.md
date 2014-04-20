Qemu 2.0
----
系统模拟
----
#### x86   
+ Q35的HPET中断可以被挂载到GSIs 16~23，和真实的设备一致   
+ Q35支持CPU hotplug了
+ 可以通过指定“-drive if=pflash"或者”-pflash“两次设置两个flash设备
+ 内存layout有些许变化。   
  为了改善性能，对内存大于3.5GB的PIIX类型的Guest（”-M pc“）拥有3GB低址内存（而非之前的3.5GB)；   
  对大于2.75GB的Q35类型的Guest（”-M q35")拥有2GB的低址内存（而非之前的2.75GB）。 
+ 支持Intel MPX寄存器的迁移
+ Apple SMC设备现在通过ACPItables暴露。
+ PIIX类型的虚拟机，支持bridge后的设备的PCI hotplug（只支持不是通过hotplug添加的bridges。hot-plugged bridge仍然可以使用PCI标准Hot-Plug controller)
+ 支持通过“-cpu”下的子参数“hv-time"添加Hyper-V reference time counter。可以提供windows虚拟机的性能，尤其是其中运行了很多浮点、SIMD运算的应用。（需要KVM和内核版本3.14)
+ qemupciserial.inf文件允许在windows上安装multiport PCI串行设备。  
+ QEMU生成的ACPI tables现在可以被OVMF固件使用了。OVMF必须使用SVN r15420。particular hotplug/pvpanic device和其他基于ACPI的特性现在可以在OVMF下运行。      

#### kvm      
+ x2apic现在默认开启（kvm下）。

设备模拟
----
#### SCSI
+ SCSI层可以卸载WRITE SAME指令到host storage上。目前XFS文件系统，raw设备、iscsi targes支持。
+ SCSI磁盘可以提供port WWN和port index信息，和真实的SAS磁盘行为更相似。

#### USB
+ XHCI控制器支持suspend-to-RAM
+ 支持微软descriptors，使windows默认使用remote suspend

#### GUI
+ 支持SDL2.0

#### VNC   
+ 改善性能。
+ 通过monitor设置密码不会再附带生效密码的效果。使用“qemu -vnc ${display},password"生效密码。

#### monitor  
+ HMP支持cpu-add指令
+ QMP支持object_add/object_del指令
+ HMP支持object_add/object_del指令
+ 改进了device_add/device_del命令自动完成
+ dump-guest-memory将产生kdump压缩格式的文件

#### Migration  
+ qcow2格式的迁移进行了大量的bug fix，现在运行更加稳定了。
+ 减少迁移中guest停顿
+ RDMA迁移使用”rdma:HOST:PORT“激活（过去是”x-rdma:HOST:PORT)

#### Network  
+ BSD系统上支持“netmap”新后端

#### Block device  

