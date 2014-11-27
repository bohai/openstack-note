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
In our deployment eth3 on the control node is a non-IP’ed interface and we will use it as the connection point to the external public network. To do that we simply add eth3 to a bridge on OVS called “br-ex”. This is the bridge Neutron will route the traffic to when a VM is connecting with the public network:

<pre><code>
# ovs-vsctl add-port br-ex eth3
# ovs-vsctl show
8a069c7c-ea05-4375-93e2-b9fc9e4b3ca1
.
.
.
    Bridge br-ex
        Port br-ex
            Interface br-ex
                type: internal
        Port "eth3"
            Interface "eth3"
.
.
.
</code></pre>

For this exercise we have created a public network with the IP range 180.180.180.0/24 accessible from eth3. This public network is provided from the datacenter side and has a gateway at 180.180.180.1 which connects it to the datacenter network. To connect this network to our OpenStack deployment we will create a subnet on our “my-public” network with the same IP range and tell Neutron what is its gateway:

![router-public-net](https://blogs.oracle.com/ronen/resource/openstack-public-network/router-public-net.png)

<pre><code>
# neutron subnet-create my-public 180.180.180.0/24 --name public_subnet --enable_dhcp=False --allocation-pool start=180.180.180.2,end=180.180.180.100 --gateway=180.180.180.1
Created a new subnet:
+------------------+------------------------------------------------------+
| Field            | Value                                                |
+------------------+------------------------------------------------------+
| allocation_pools | {"start": "180.180.180.2", "end": "180.180.180.100"} |
| cidr             | 180.180.180.0/24                                     |
| dns_nameservers  |                                                      |
| enable_dhcp      | False                                                |
| gateway_ip       | 180.180.180.1                                        |
| host_routes      |                                                      |
| id               | ecadf103-0b3b-46e8-8492-4c5f4b3ea4cd                 |
| ip_version       | 4                                                    |
| name             | public_subnet                                        |
| network_id       | 5eb99ac3-905b-4f0e-9c0f-708ce1fd2303                 |
| tenant_id        | 9796e5145ee546508939cd49ad59d51f                     |
+------------------+------------------------------------------------------+
</code></pre>

Next we need to connect the router to our newly created public network, we do this using the following command:

<pre><code>
# neutron router-gateway-set my-router my-public
Set gateway for router my-router
</pre></code>

Note: We use the term “public network” for two things, one is the actual public network available from the datacenter (180.180.180.0/24) for clarity we’ll call this network “external public network”. The second place we use the term “public network” is within OpenStack for the network we call “my-public” which is the interface network inside the OpenStack deployment. We also refer to two “gateways”, one of them is the gateway used by the external public network (180.180.180.1) and another is the gateway interface on the router (180.180.180.2).

After performing the operation above the router which had two interfaces is also connected to a third interface which is called gateway (this is the router gateway). A router can have multiple interfaces, to connect to regular internal subnets, and one gateway to connect to the “my-public” network. A common mistake would be to try to connect the public network as a regular interface, the operation can succeed but no connection will be made to the external world. After we have created a public network, a subnet and connected them to the router we the network topology view will look like this:

Looking into the router’s namespace we see that another interface was added with an IP on the 180.180.180.0/24 network, this IP is 180.180.180.2 which is the router gateway interface:

<pre><code>
# ip netns exec qrouter-fce64ebe-47f0-4846-b3af-9cf764f1ff11 ip addr
.
.
22: qg-c08b8179-3b: <BROADCAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN                                                      
    link/ether fa:16:3e:a4:58:40 brd ff:ff:ff:ff:ff:ff
    inet 180.180.180.2/24 brd 180.180.180.255 scope global qg-c08b8179-3b
    inet6 2606:b400:400:3441:f816:3eff:fea4:5840/64 scope global dynamic
       valid_lft 2591998sec preferred_lft 604798sec
    inet6 fe80::f816:3eff:fea4:5840/64 scope link
       valid_lft forever preferred_lft forever
.
.
</code></pre>
At this point the router’s gateway (180.180.180.2) address is connected to the VMs and the VMs can ping it. We can also ping the external gateway (180.180.180.1) from the VMs as well as reach the network this gateway is connected to.

If we look into the router namespace we see that two lines are added to the NAT table in iptables:

<pre><code>
# ip netns exec qrouter-fce64ebe-47f0-4846-b3af-9cf764f1ff11 iptables-save
.
.
-A neutron-l3-agent-snat -s 20.20.20.0/24 -j SNAT --to-source 180.180.180.2
-A neutron-l3-agent-snat -s 10.10.10.0/24 -j SNAT --to-source 180.180.180.2
 
.
.
</code></pre>
This will change the source IP of outgoing packets from the networks net1 and net2 to 180.180.180.2. When we ping from within the VMs will one the network we will see as if the request comes from this IP address.

The routing table inside the namespace will route any outgoing traffic to the gateway of the public network as we defined it when we created the subnet, in this case 180.180.180.1

<pre><code>
#  ip netns exec  qrouter-fce64ebe-47f0-4846-b3af-9cf764f1ff11 route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         180.180.180.1   0.0.0.0         UG    0      0        0 qg-c08b8179-3b
10.10.10.0      0.0.0.0         255.255.255.0   U     0      0        0 qr-15ea2dd1-65
20.20.20.0      0.0.0.0         255.255.255.0   U     0      0        0 qr-dc290da0-0a
180.180.180.0   0.0.0.0         255.255.255.0   U     0      0        0 qg-c08b8179-3b
</code></pre>
 
Those two pieces will assure that a request from a VM trying to reach the public network will be NAT’ed to 180.180.180.2 as a source and routed to the public network’s gateway. We can also see that ip forwarding is enabled inside the namespace to allow routing:
<pre><code>
# ip netns exec qrouter-fce64ebe-47f0-4846-b3af-9cf764f1ff11 sysctl net.ipv4.ip_forward
net.ipv4.ip_forward = 1
 </code></pre>
