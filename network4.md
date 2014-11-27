### 深入理解openstack网络架构(4)-----连接到public network
上一篇文章中我们介绍了openstack中的路由，我们了解到openstack如何通过namespace实现router将两个network连通。本文中，我们进一步探索路由能力，说明如何在内部internal network和public network直接路由（而不仅仅是internal network之间）。我们见看到neutron如何将浮动IP配置给虚拟机，从而实现public network与虚拟机的连通。

### Use case #5: Connecting VMs to the public network  
A “public network”, for the purpose of this discussion, is any network which is external to the OpenStack deployment. This could be another network inside the data center or the internet or just another private network which is not controlled by OpenStack.

To connect the deployment to a public network we first have to create a network in OpenStack and designate it as public. This network will be the target for all outgoing traffic from VMs inside the OpenStack deployment. At this time VMs cannot be directly connected to a network designated as public, the traffic can only be routed from a private network to a public network using an OpenStack created router. To create a public network in OpenStack we simply use the net-create command from Neutron and setting the router:external option as True. In our example we will create public network in OpenStack called “my-public”:

<pre><code>
# neutron net-create my-public --router:external=True
Created a new network:
+---------------------------+--------------------------------------+
| Field                     | Value                                |
+---------------------------+--------------------------------------+
| admin_state_up            | True                                 |
| id                        | 5eb99ac3-905b-4f0e-9c0f-708ce1fd2303 |
| name                      | my-public                            |
| provider:network_type     | vlan                                 |
| provider:physical_network | default                              |
| provider:segmentation_id  | 1002                                 |
| router:external           | True                                 |
| shared                    | False                                |
| status                    | ACTIVE                               |
| subnets                   |                                      |
| tenant_id                 | 9796e5145ee546508939cd49ad59d51f     |
+---------------------------+--------------------------------------+
</code></pre>
