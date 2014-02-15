###openstack虚拟机快照
目前openstack的虚拟机快照只快照root盘，不快照内存/CPU状态以及挂载磁盘。  
因此挂载磁盘需要事先卸载磁盘，然后进行快照，然后再挂载磁盘。  
（QEMU 1.3+ and libvirt 1.0+ ）后支持livesnapshot。

+   制作livesnapshot过程：  
    1.  flush虚拟机中的数据到磁盘，并冻结文件系统    
    主要使用sync,fsfreeze等命令  
    2.  创建虚拟机快照  
    <pre><code>$ nova image-create myCirrosServer myCirrosImage</code></pre>

+   使用image创建虚拟机：  
    1.  查看image
    <pre><code>$ nova image-show IMAGE </code></pre> 
    2.  创建虚拟机
    <pre><code>$ nova boot newServer --image 7e5142af-1253-4634-bcc6-89482c5f2e8a \
   --flavor 3</code></pre>

+ 其他：通过image的properties还可以设置disk_bus, cdrom_bus, and vif_model       
<pre><code>$ glance image-update \
    --property hw_disk_bus=scsi \
    --property hw_cdrom_bus=ide \
    --property hw_vif_model=e1000 \
    f16-x86_64-openstack-sda
</code></pre>

+ 缺点（nova 快照的一些限制。）：  
    +  不支持内存快照，只支持卷快照 
    +  只对系统盘进行快照 
    +  没有快照链信息 
    +  需要用户进行一致性操作 
    +  不支持含元数据导出 
    +  不支持含元数据导入


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

更详细流程待pdb研究.
是否为全量快照？看似不支持增量快照。


###当前快照导入、导出能力
+ 虚拟机快照导入
    1.  使用nova image-create创建虚拟机快照
    2.  通过glance image-download <Image ID> --file filename.img导出虚拟机快照
+ 虚拟机快照导入
    1.  通过glance image-create --file导入虚拟机快照

###待完善
+ 快照树  
  目前虚拟机快照未保存快照链信息，只能知道时间先后顺序，无法知道快照关系。
+ 导出包含metadata的image  
  便于后续重新导入image

###其他
openstack和版本对快照的思路略有不同。openstack因为存在镜像管理，所以虚拟机快照更多的是
通过镜像方式管理。而版本不存在镜像管理，更多的是通过存储来保存和使用镜像。

###BP列表
+ 在线虚拟机快照（包含内存、CPU状态）   开发中  Next  
https://blueprints.launchpad.net/nova/+spec/live-snapshot-vms
+ Live snapshot基础能力                                   完成（好像根本没做）  
https://blueprints.launchpad.net/nova/+spec/live-snapshots
+ libvirt无中断快照                                            完成  
https://blueprints.launchpad.net/nova/+spec/libvirt-live-snapshots
+ Qemu辅助卷快照（带内部VSS等？）               完成  
https://blueprints.launchpad.net/nova/+spec/qemu-assisted-snapshots
https://wiki.openstack.org/wiki/Cinder/GuestAssistedSnapshotting
+ Instacne全卷快照：                                        draft阶段  
https://blueprints.launchpad.net/nova/+spec/instance-level-snapshots
+ Lined clone：                                                 draft阶段  
https://blueprints.launchpad.net/nova/+spec/linked-snapshot
+ 感觉像是利用linked clone快速clone虚拟机  
https://blueprints.launchpad.net/nova/+spec/nova-fast-snapshot

###备注 
[1]: http://docs.openstack.org/user-guide/content/cli_manage_images.html#glance-image-list 
[2]: http://docs.openstack.org/trunk/openstack-ops/content/snapshots.html  
[3]: http://www.sebastien-han.fr/blog/2012/12/10/openstack-perform-consistent-snapshots/
[4]: http://docs.openstack.org/image-guide/content/



