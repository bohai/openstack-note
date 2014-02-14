###openstack虚拟机快照
目前openstack的虚拟机快照只快照root盘，不快照内存/CPU状态以及挂载磁盘。  
因此挂载磁盘需要事先卸载磁盘，然后进行快照，然后再挂载磁盘。  
（QEMU 1.3+ and libvirt 1.0+ ）后支持livesnapshot。

制作livesnapshot过程：  
1.  flush虚拟机中的数据到磁盘，并冻结文件系统    
    主要使用sync,fsfreeze等命令  
2.  创建虚拟机快照  
    <pre><code>$ nova image-create myCirrosServer myCirrosImage</code></pre>

使用image创建虚拟机：  
1.  查看image
    <pre><code>$ nova image-show IMAGE </code></pre> 
2.  创建虚拟机
    <pre><code>$ nova boot newServer --image 7e5142af-1253-4634-bcc6-89482c5f2e8a \
   --flavor 3</code></pre>

其他：通过image的properties还可以设置disk_bus, cdrom_bus, and vif_model       
<pre><code>$ glance image-update \
    --property hw_disk_bus=scsi \
    --property hw_cdrom_bus=ide \
    --property hw_vif_model=e1000 \
    f16-x86_64-openstack-sda
</code></pre>

###虚拟机快照当前的BP
-  包含内存、CPU状态等数据的快照。  
该BP目前计划解决该问题（目前代码已经完成，在review中）：  
https://blueprints.launchpad.net/nova/+spec/live-snapshot-vms  
-  虚拟机所有盘的快照。  
该BP还在draft解决，完全没有开始：  
https://blueprints.launchpad.net/nova/+spec/instance-level-snapshots

###虚拟机快照的流程
nova image-create的流程：  
1.  获取token  
2.  查询虚拟机状态  
3.  创建虚拟机快照  
>curl -i http://186.100.8.214:8774/v2/86196260e1694d0cbb5049cfba3883f8/servers/6c2504f4-efa-47ec-b6f4-06a9fde8a00b/action -X POST -H "X-Auth-Project-Id: admin" -H "User-Agent: python-novaclient" -H "Content-Type: application/json" -H "Accept: application/json" -H "X-Auth-Token: " -d '{"createImage": {"name": "nova_100_new_01", "metadata": {}}}'

createImage快照流程：  
>外部消息----->nova api（函数_action_create_image）----->nova compute api（函数snapshot_volume_backed）----->volume api(函数create_snapshot_force）
            |--->glance(函数create，创建image)

###快照导入导出的实现


###待完善内容
+ 快照树  
  目前虚拟机快照未保存快照链信息，只能知道时间先后顺序，无法知道快照关系。

###备注  

