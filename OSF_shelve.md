openstack shelve/unshelve/stop浅析
----



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
