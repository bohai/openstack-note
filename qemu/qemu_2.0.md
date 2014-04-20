Qemu 2.0
----
#### x86
+ Q35的HPET中断可以被挂载到GSIs 16~23，和真实的设备一致   
+ Q35支持CPU hotplug了
+ 可以通过指定“-drive if=pflash"或者”-pflash“两次设置两个flash设备
+ 内存layout有些许变化。   
  为了改善性能，对内存大于3.5GB的PIIX类型的Guest（”-M pc“）拥有3GB低址内存（而非之前的3.5GB)；   
  对大于2.75GB的Q35类型的Guest（”-M q35")拥有2GB的低址内存（而非之前的2.75GB）。      
