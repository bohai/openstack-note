### 深入理解openstack网络架构(4)-----连接到public network
上一篇文章中我们介绍了openstack中的路由，我们了解到openstack如何通过namespace实现router将两个network连通。本文中，我们进一步探索路由能力，说明如何在内部internal network和public network直接路由（而不仅仅是internal network之间）。   
我们见看到neutron如何将浮动IP配置给虚拟机，从而实现public network与虚拟机的连通。

### Use case #5: Connecting VMs to the public network  
所谓“public network”，指openstack部署环境以外的网络。这个网络可以是datacenter中的另一个网络、internet、或者一个不被openstack控制的私有网络。   

与public network连通，我们需要在openstack中创建一个network并设置为public。这个网络用于虚拟机外部流量传输。同时虚拟机不能直接连接到属性为public的network，所有网络流量必须使用openstack创建的router从private network路由到public network。在openstack中创建public network，我们只需要使用neutron net-create 命令，并将router:external设置为True。     
在我们的例子中，public newtork叫做“my-public”。   
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

在我们的环境中，控制节点的eth3是一个没有绑定IP的网络接口。我们使用它作为连接点接入外部public network。我们通过将eth3接入OVS网桥"br-ex"。这个bridge用于虚拟机向外部网络的流量进行路由。

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

在上边的练习中，我们创建了一个public network，IP范围是180.180.180.0/24，通过eth3接入。这个public network存在于datacenter中，通过gateway 180.180.180.1可以连接到datacenter网络。为了将这个网络与Openstack环境相连，我们需要创建一个叫“my-public"的network，
这个network有相同的IP范围，而且需要告诉neutron这个网络的gateway。

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

然后，我们需要将router接入我们新创建的public network,使用下列命令创建：

<pre><code>
# neutron router-gateway-set my-router my-public
Set gateway for router my-router
</code></pre>

注意：我们在两种情况下使用术语“public network",一个是datacenter中真实的public network，为了区分我们把它（180.180.180.0/24）叫做"external public network"。另一个是openstack中我们使用的"public network"，我们称之为“my-public"的接口网络。
我们还涉及两个”gateways“，一个是外部Public network用的gateway（180.180.180.1），另一个是router中的gateway接口（180.180.180.2）。     
     
执行上述的操作后，已经拥有两个网络接口的router现在增加了第三个网络接口（被称作gateway）。router可以有多个网络接口，连接通常的internal subnet或者作为gateway连入“my-public"网络。一个经常犯的错误是，试图以通常网络接口的方式接入public network，操作可能成功，但是却并不能与外部网络连通。
在我们创建一个public network，subnet并接入router，网络拓扑看起来是这样的:    

![router-public-net](https://blogs.oracle.com/ronen/resource/openstack-public-network/router-public-net.png)   

进入router的namespace中，我们看到其中增加了一个180.180.180.0/24网段IP的网络接口，IP为180.180.180.2：  

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
在这里router的gateway地址180.180.180.2与虚拟机是联通的，虚拟机可以ping到它。我们也能从虚拟机ping到外部网络的gateway180.180.180.1以及这个gateway所连的网络。
如果我们查看router namespace，发现iptables的NAT talbe中有以下两行规则。

<pre><code>
# ip netns exec qrouter-fce64ebe-47f0-4846-b3af-9cf764f1ff11 iptables-save
.
.
-A neutron-l3-agent-snat -s 20.20.20.0/24 -j SNAT --to-source 180.180.180.2
-A neutron-l3-agent-snat -s 10.10.10.0/24 -j SNAT --to-source 180.180.180.2
 
.
.
</code></pre>

因此，从net1或net2向外网发出的网络包，其源IP地址会被修改为180.180.180.2。我们可以在虚拟机中ping外网的某个地址，看下请求包的IP地址是否是这个IP地址。

namespace中的路由表会把所有外部流量路由到外网的gateway（180.180.180.1）。  

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
虚拟机中发出的流向public network的请求，会被NAT映射为源地址为180.180.180.2，然后发给public network的gateway。同样，我们可以看到在namespace中ip forward功能是启动的。  

<pre><code>
# ip netns exec qrouter-fce64ebe-47f0-4846-b3af-9cf764f1ff11 sysctl net.ipv4.ip_forward
net.ipv4.ip_forward = 1
 </code></pre>

### Use case #6: Attaching a floating IP to a VM   

现在，虚拟机可以访问public network。下一步，我们尝试允许外部客户访问Openstack环境中的虚拟机，我们通过floating IP完成这个功能。 Floating IP由外部网络提供，用户可以将它设置给虚拟机，从而允许外部客户接入虚拟机。

创建Floating IP，第一步是按照之前usecase的讲解，将虚拟机连入外部网络。第二步时使用命令行，产生一个浮动IP。

<pre><code>
# neutron floatingip-create public
Created a new floatingip:
+---------------------+--------------------------------------+
| Field               | Value                                |
+---------------------+--------------------------------------+
| fixed_ip_address    |                                      |
| floating_ip_address | 180.180.180.3                        |
| floating_network_id | 5eb99ac3-905b-4f0e-9c0f-708ce1fd2303 |
| id                  | 25facce9-c840-4607-83f5-d477eaceba61 |
| port_id             |                                      |
| router_id           |                                      |
| tenant_id           | 9796e5145ee546508939cd49ad59d51f     |
+---------------------+--------------------------------------+
 </code></pre>
 
根据"my-public" network的能力，用户可以创建很多这样的IP。将浮动IP与虚拟机关联，可以通过命令行或者GUI完成。
下图是GUI的例子：  

![connect-floatingip](https://blogs.oracle.com/ronen/resource/openstack-public-network/connect-floatingip.png)

Under the hood we can look at the router namespace and see the following additional lines in the iptables of the router namespace:

<pre><code>
-A neutron-l3-agent-OUTPUT -d 180.180.180.3/32 -j DNAT --to-destination 20.20.20.2
-A neutron-l3-agent-PREROUTING -d 180.180.180.3/32 -j DNAT --to-destination 20.20.20.2
-A neutron-l3-agent-float-snat -s 20.20.20.2/32 -j SNAT --to-source 180.180.180.3
 </code></pre>
These lines are performing the NAT operation for the floating IP. In this case if and incoming request arrives and its destination is 180.180.180.3 it will be translated to 20.20.20.2 and vice versa.

Once a floating IP is associated we can connect to the VM, it is important to make sure there are security groups rule which will allow this for example:
<pre><code>
nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
  </code></pre>
  
Those will allow ping and ssh.

Iptables is a sophisticated and powerful tool, to better understand all the bits and pieces on how the chains are structured in the different tables we can look at one of the many iptables tutorials available online and read more to understand any specific details.

### Summary

This post was about connecting VMs in the OpenStack deployment to a public network. It shows how using namespaces and routing tables we can route not only inside the OpenStack environment but also to the outside world.

This will also be the last post in the series for now. Networking is one of the most complicated areas in OpenStack and gaining good understanding of it is key. If you read all four posts you should have a good starting point to analyze and understand different network topologies in OpenStack. We can apply the same principles shown here to understand more network concepts such as Firewall as a service, Load Balance as a service, Metadata service etc. The general method will be to look into a namespace and figure out how certain functionality is implemented using the regular Linux networking features in the same way we did throughout this series.

As we said in the beginning, the use cases shown here are just examples of one method to configure networking in OpenStack and there are many others. All the examples here are using the Open vSwitch plugin and can be used right out of the box. When analyzing another plugin or specific feature operation it will be useful to compare the features here to their equivalent method with the plugin you choose to use. In many cases vendor plugins will use Open vSwitch , bridges or namespaces and some of the same principles and methods shown here.

The goal of this series is to make the OpenStack networking accessible to the average user. This series takes a bottom up approach and using simple use cases tries to build a complete picture of how the network architecture is working. Unlike some other resources we did not start out by explaining the different agents and their functionality but tried to explain what they do , how does the end result looks like. A good next step would be to go to one of those resources and try to see how the different agents implement the functionality explained here.

That’s it for now
