验证core绑定策略
========

主机共有3个CPU，3个node：
CPU1有2个core，4个thread。
CPU2有1个core，2个thread。
CPU3有1个core，2个thread。


openstack flavor create --ram 1024 --vcpu 2 --disk 1 isolate
openstack flavor set isolate --property hw:cpu_policy=dedicated --property hw:cpu_thread_policy=isolate

openstack server create --flavor isolate  --image  cirros-0.3.4-x86_64-uec isolate
创建成功。

openstack server create --flavor isolate  --image  cirros-0.3.4-x86_64-uec isolate2
创建成功。
原因：openstack默认一个numa node。虽然还有两个core，但是不在1个node。openstack因此返回失败。

openstack flavor create --ram 1024 --vcpu 1 --disk 1 isolate_1u
openstack flavor set isolate_1u --property hw:cpu_policy=dedicated --property hw:cpu_thread_policy=isolate

openstack server create --flavor isolate_1u   --image  cirros-0.3.4-x86_64-uec isolate_1u1
创建成功。
openstack server create --flavor isolate_1u   --image  cirros-0.3.4-x86_64-uec isolate_1u2
创建成功。
openstack server create --flavor isolate_1u   --image  cirros-0.3.4-x86_64-uec isolate_1u3
创建失败，因为已经没有空余的core了。

通过xml也可以看出3个虚拟机使用了0,2,4,6四个pCPUs。

验证thread分配策略
========

openstack flavor create --ram 1024 --vcpu 2 --disk 1 prefer
openstack flavor set prefer --property hw:cpu_policy=dedicated --property hw:cpu_thread_policy=prefer
openstack server create --flavor prefer  --image  cirros-0.3.4-x86_64-uec prefer
创建失败，因为资源不足。

删除虚拟机isolate后，重新创建prefer，创建成功。
通过xml可以看出使用了0,1两个pCPUs。
openstack的分配策略是按顺序使用未用的pCPUs。

这样做的好处，避免thread碎片。

require的行为
========

openstack flavor create --ram 1024 --vcpu 2 --disk 1 require
openstack flavor set require --property hw:cpu_policy=dedicated --property hw:cpu_thread_policy=require
openstack server create --flavor require  --image  cirros-0.3.4-x86_64-uec require
openstack server create --flavor require  --image  cirros-0.3.4-x86_64-uec require2

可以创建成功，分别使用0,1和2,3

openstack server create --flavor require  --image  cirros-0.3.4-x86_64-uec require3
创建失败，因为没有资源了。









