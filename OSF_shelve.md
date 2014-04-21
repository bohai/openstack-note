openstack shelve/unshelve/stop浅析
----
stop的虚拟机只是将虚拟机停止，并未在hypervisor释放改虚拟机。虚拟机仍然占用着临时存储资源。      
系统也为虚拟机保留着cpu/memory资源，以确保启动可以成功。    

当我们需要彻底释放cpu/memory/临时存储资源，我们引入了shelve。    
shelve原理是将虚拟机从hypervisor上释放。虚拟机的cpu/memory不再预留。    
对临时存储，我们通过快照将磁盘数据放置在glance上。  
对cinder后端的存储，我们无须这么复杂。  

shelve包含三个操作：  
shelve           :将虚拟机停止并设置为shelved状态。将临时存储进行快照，并存放在glance上。    
                  等待shelve-offload操作或者shelve周期到达。    
shelve-offload   :将shelved的虚拟机从hypervisor上彻底释放。虚拟机状态转变为shelve-offload。  
unshelve         :重新选择节点启动处于shelve-offload状态的虚拟机。（之后会删除glance上的镜像）   
一个周期性任务：   
坚持处于shelved状态的虚拟机，当shelve周期到达，将虚拟机从hypervisor上释放。  

存在的缺点：   
1. unshelve可能由于资源不足而失败。    
2. 启动速度比stop的虚拟机启动慢。尤其是临时存储（需要下载镜像）。  
3. 只对系统盘进行快照，因此其他盘数据会丢失(临时存储时）。  
4. 由于快照时，临时存储的差分卷和母卷合并了，因此unshelve后占用的临时存储会增大。（相当于有多份母卷）  


```
[root@localhost devstack(keystone_admin)]# nova list --all-tenants
+--------------------------------------+------+--------+------------+-------------+------------------+
| ID                                   | Name | Status | Task State | Power State | Networks         |
+--------------------------------------+------+--------+------------+-------------+------------------+
| 3d9570c3-069a-4510-96c2-9a6fb8853484 | 11   | ACTIVE | -          | Running     | private=10.0.0.3 |
+--------------------------------------+------+--------+------------+-------------+------------------+
[root@localhost devstack(keystone_admin)]# nova stop 3d9570c3-069a-4510-96c2-9a6fb8853484
[root@localhost devstack(keystone_admin)]# nova list --all-tenants
+--------------------------------------+------+---------+------------+-------------+------------------+
| ID                                   | Name | Status  | Task State | Power State | Networks         |
+--------------------------------------+------+---------+------------+-------------+------------------+
| 3d9570c3-069a-4510-96c2-9a6fb8853484 | 11   | SHUTOFF | -          | Shutdown    | private=10.0.0.3 |
+--------------------------------------+------+---------+------------+-------------+------------------+
[root@localhost devstack(keystone_admin)]# virsh list
 Id    名称                         状态
----------------------------------------------------

[root@localhost devstack(keystone_admin)]# virsh list --all
 Id    名称                         状态
----------------------------------------------------
 -     instance-0000000a              关闭

[root@localhost devstack(keystone_admin)]# nova shelve 3d9570c3-069a-4510-96c2-9a6fb8853484
[root@localhost devstack(keystone_admin)]# virsh list --all
 Id    名称                         状态
----------------------------------------------------
```
