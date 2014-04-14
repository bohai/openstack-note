网卡
From Coswiki
Jump to: navigation, search
一、准备工作： 

1、对于Intel CPU需要的准备操作：
1>主机host的BIOS需要打开Intel VT-d extensions选项。
2>在kernel中激活Intel VT-d
在/boot/grub2/grub.cfg文件中的kernel行的最后添加intel_iommu=on参数
例如：
    linux   /vmlinuz-3.6.3-1.fc17.x86_64 root=/dev/mapper/vg_fedora-lv_root ro rd.md=0 rd.dm=0 SYSFONT=True rd.lvm.lv=v
         g_fedora/lv_swap rd.lvm.lv=vg_fedora/lv_root rd.luks=0  KEYTABLE=us-acentos LANG=en_US.UTF-8 rhgb quiet intel_iommu=on 
2、对于AMD CPU的准备操作：
只需要在主机host的BIOS需要打开 AMD IOMMU extensions选项。

二、使用libvirt配置直通： 

1、使用virsh nodedev-list命令查看当前host系统中所有的设备：
# virsh nodedev-list --tree
computer
  |
  +- net_lo_00_00_00_00_00_00
  +- net_p51p1_5_90_e2_ba_00_d1_c2
  +- net_p51p1_6_90_e2_ba_00_d1_c2
  +- net_p51p1_7_90_e2_ba_00_d1_c2
  +- net_virbr0_nic_52_54_00_e6_ce_81
  +- pci_0000_00_00_0
  +- pci_0000_00_01_0
  |   |
  |   +- pci_0000_01_00_0
  |   |   |
  |   |   +- net_p49p1_54_89_98_f6_f9_bd
  |   |     
  |   +- pci_0000_01_00_1
  |       |
  |       +- net_p49p2_54_89_98_f6_f9_be
  |         
  +- pci_0000_00_03_0
  |   |
  |   +- pci_0000_02_00_0
  |   |   |
  |   |   +- net_p51p1_90_e2_ba_00_d1_c2
  |   |     
  |   +- pci_0000_02_00_1
  |       |
  |       +- net_p51p2_90_e2_ba_00_d1_c3
  |         
  +- pci_0000_00_07_0
  |   |
  |   +- pci_0000_03_00_0
  |   |   |
  |   |   +- net_p55p1_90_e2_ba_00_cd_ee
  |   |     
  |   +- pci_0000_03_00_1
  |       |
  |       +- net_p55p2_90_e2_ba_00_cd_ef
  ......
也可以使用lspci命令进行设备确认：
# lspci
......
01:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
01:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
02:00.0 Ethernet controller: Intel Corporation 82576 Gigabit Network Connection (rev 01)
02:00.1 Ethernet controller: Intel Corporation 82576 Gigabit Network Connection (rev 01)
03:00.0 Ethernet controller: Intel Corporation 82576 Gigabit Network Connection (rev 01)
03:00.1 Ethernet controller: Intel Corporation 82576 Gigabit Network Connection (rev 01)
......

2、查看设备详细信息，我们已pci_0000_03_00_0对应的网卡为例：
# virsh nodedev-dumpxml pci_0000_03_00_0
<device>
  <name>pci_0000_03_00_0</name>
  <parent>pci_0000_00_07_0</parent>
  <driver>
    <name>igb</name>
  </driver>
  <capability type='pci'>
    <domain>0</domain>
    <bus>3</bus>
    <slot>0</slot>
    <function>0</function>
    <product id='0x10c9'>82576 Gigabit Network Connection</product>
    <vendor id='0x8086'>Intel Corporation</vendor>
  </capability>
</device>

3、从主机中detach要被直通的PCI设备：
# virsh nodedev-dettach pci_0000_03_00_0

4、在虚拟机xml中，添加如下内容，其中domain、bus、slot、function的值为virsh nodedev-dumpxml命令查询结果中的值，但是要将其从十进制转为十六进制：
  <devices>
     ......
     <hostdev mode='subsystem' type='pci' managed='yes'>
       <source>
         <address domain='0x0000' bus='0x03' slot='0x00' function='0x0'/>
       </source>
     </hostdev>
     ......
  </devices>
  
5、启动虚拟机：
# virsh create winxp.xml

6、在虚拟机中查看新增的pci设备。
三、使用libvirt热插拔PCI直通： 

1、同上第1步
2、同上第2步
3、同上第3步
4、创建xml文件pci.xml。其内容如下，其中domain、bus、slot、function的值为virsh nodedev-dumpxml命令查询结果中的值，但是要将其从十进制转为十六进制：
<hostdev mode='subsystem' type='pci' managed='yes'>
  <source>
    <address domain='0x0000' bus='0x03' slot='0x00' function='0x0'/>
  </source>
</hostdev>
5、使用virsh attach-device命令动态添加PCI设备：
virsh attach-device <domain-name> <xml-file>
例如：
virsh attach-device winxp pci.xml
6、在虚拟机中查看新增的PCI设备。
7、删除PCI设备：
virsh attach-device <domain-name> <xml-file>
例如：
virsh detach-device winxp pci.xml
四、使用qemu配置直通： 

1、使用lspci命令进行设备确认：
使用lspci获得bus、slot、function的值(domain:bus:slot.function)
# lspci -D
......
0000:01:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
0000:01:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
0000:02:00.0 Ethernet controller: Intel Corporation 82576 Gigabit Network Connection (rev 01)
0000:02:00.1 Ethernet controller: Intel Corporation 82576 Gigabit Network Connection (rev 01)
0000:03:00.0 Ethernet controller: Intel Corporation 82576 Gigabit Network Connection (rev 01)
0000:03:00.1 Ethernet controller: Intel Corporation 82576 Gigabit Network Connection (rev 01)
......
使用lspci -n根据(domain:bus:slot.function)获得对应PCI设备的(vendor id:product id)
# lspci -D -n
......
0000:01:00.0 0200: 14e4:1639 (rev 20)
0000:01:00.1 0200: 14e4:1639 (rev 20)
0000:02:00.0 0200: 8086:10c9 (rev 01)
0000:02:00.1 0200: 8086:10c9 (rev 01)
0000:03:00.0 0200: 8086:10c9 (rev 01)
0000:03:00.1 0200: 8086:10c9 (rev 01)
......
也可直接使用lspci -nn命令获得PCI设备的(domain:bus:slot.function)和(vendor id:product id)
# lspci -D -nn
......
0000:01:00.0 Ethernet controller [0200]: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet [14e4:1639] (rev 20)
0000:01:00.1 Ethernet controller [0200]: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet [14e4:1639] (rev 20)
0000:02:00.0 Ethernet controller [0200]: Intel Corporation 82576 Gigabit Network Connection [8086:10c9] (rev 01)
0000:02:00.1 Ethernet controller [0200]: Intel Corporation 82576 Gigabit Network Connection [8086:10c9] (rev 01)
0000:03:00.0 Ethernet controller [0200]: Intel Corporation 82576 Gigabit Network Connection [8086:10c9] (rev 01)
0000:03:00.1 Ethernet controller [0200]: Intel Corporation 82576 Gigabit Network Connection [8086:10c9] (rev 01)
......


2、从主机中detach要被直通的PCI设备：
以下以0000:03:00.0对应的网卡为例，其vendor id和product id为0x8086和0x10c9
echo "8086 10c9" > /sys/bus/pci/drivers/pci-stub/new_id
echo "0000:03:00.0" > /sys/bus/pci/drivers/igb/unbind
echo "0000:03:00.0" > /sys/bus/pci/drivers/pci-stub/bind
echo "8086 10c9" > /sys/bus/pci/drivers/pci-stub/remove_id

3、启动虚拟机：
qemu-kvm -enable-kvm -m 1024 -smp 2 -boot c -drive file=/home/vm/winxp.qcow2,if=none,id=drive0,format=qcow2 -device virtio-blk-pci,scsi=off,drive=drive0,id=disk0 -monitor stdio -vnc 186.100.8.170:1 -device pci-assign,host=0000:03:00.0
五、使用qemu热插拔PCI直通： 

1、同上面的第一步
2、同上面的第二步
3、启动虚拟机
qemu-kvm -enable-kvm -m 1024 -smp 2 -boot c -drive file=/home/vm/winxp.qcow2,if=none,id=drive0,format=qcow2 -device virtio-blk-pci,scsi=off,drive=drive0,id=disk0 -monitor stdio -vnc 186.100.8.170:1
4、热插pci直通设备：
device_add pci-assign,host=0000:03:00.0,id=new_pci_device
5、热拔pci直通设备：
device_del new_pci_device
