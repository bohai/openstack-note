### 深入理解openstack网络架构(4)-----连接到public network
在上一篇文章中，我们介绍了openstack中的路由，了解到openstack如何通过namespace实现的router将两个network连通。本文中，我们进一步分析路由功能，说明实现内部internal network和public network的路由（而不仅仅是internal network之间）。   
我们还会分析neutron如何将浮动IP配置给虚拟机，从而实现public network与虚拟机的连通。

### Use case #5: Connecting VMs to the public network  
所谓“public network”，指openstack部署环境以外的网络。这个网络可以是datacenter中的另一个网络、internet、或者一个不被openstack控制的私有网络。   

与public network通信，我们需要在openstack中创建一个network并设置为public。这个network用于虚拟机与public network通信。虚拟机不能直接连接到这个新创建的属性为public的network，所有网络流量必须使用openstack创建的router从private network路由到public network。在openstack中创建public network，我们只需要使用neutron net-create 命令，并将router:external设置为True。     
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

在我们的环境中，控制节点的eth3是一个没有绑定IP的网卡。我们使用它接入外部public network。因此我们将eth3加入OVS网桥"br-ex"，Neutron会将虚拟机向外部网络的发送的网络包路由到这个bridge。

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

我们在eth3上创建了一个IP范围是180.180.180.0/24的public network。这个public network存在于datacenter中，通过gateway 180.180.180.1可以连接到datacenter网络。为了将这个网络与Openstack环境相连，我们需要在“my-public"这个network，上创建一个有相同IP范围的subnet，并告诉neutron这个network的gateway。

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

然后，我们需要将router接入我们新创建的public network，使用下列命令创建：

<pre><code>
# neutron router-gateway-set my-router my-public
Set gateway for router my-router
</code></pre>

注意：我们在两种情况下使用术语“public network",一个是datacenter中真实的public network，为了区分我们把它（180.180.180.0/24）叫做"external public network"。另一个是openstack中我们使用的"public network"，我们称之为“my-public"的接口网络。
我们还涉及两个”gateways“，一个是外部Public network用的gateway（180.180.180.1），另一个是router中的gateway接口（180.180.180.2）。     
     
执行上述的操作后，router上（之前已经拥有两个网络接口，连接两个不同的internal network）增加了第三个网络接口（被称作gateway）。router可以有多个网络接口，连接普通的internal subnet或者作为gateway连入“my-public"网络。一个经常犯的错误是，试图以通常网络接口的方式接入public network，操作可能成功，但是却并不能与外部网络连通。
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

虚拟机中发出的流向public network的请求，会被NAT映射为源地址为180.180.180.2，然后发给public network的gateway。同样，我们可以看到在namespace中ip forward功能是启动的。  

<pre><code>
# ip netns exec qrouter-fce64ebe-47f0-4846-b3af-9cf764f1ff11 sysctl net.ipv4.ip_forward
net.ipv4.ip_forward = 1
 </code></pre>

### Use case #6: Attaching a floating IP to a VM   

现在，虚拟机可以访问public network。下一步，我们尝试允许外部客户访问Openstack环境中的虚拟机，通过floating IP可以完成这个功能。 Floating IP由外部网络提供，用户可以将它设置给虚拟机，从而允许外部客户接入虚拟机。

创建Floating IP，第一步是按照上一个usecase的讲解，将虚拟机连入外部网络。第二步时使用命令行，产生一个浮动IP。

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

在router namespace中我们可以看到，新增加了3跳iptabales规则：  

<pre><code>
-A neutron-l3-agent-OUTPUT -d 180.180.180.3/32 -j DNAT --to-destination 20.20.20.2
-A neutron-l3-agent-PREROUTING -d 180.180.180.3/32 -j DNAT --to-destination 20.20.20.2
-A neutron-l3-agent-float-snat -s 20.20.20.2/32 -j SNAT --to-source 180.180.180.3
 </code></pre>
 
这些规则主要是对Floating IP进行NAT操作。对于router收到的目的地址为180.180.180.3的请求，会被转换成目标地址为20.20.20.2。反之亦然。

绑定Floating IP后，我们可以连接到虚拟机。需要确认安全组规则已经被设置，从而允许这样连接：   

<pre><code>
nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
  </code></pre>

这两条规则，允许ping和ssh。

Iptables是一个复杂而强大的工具。如果想更好的理解iptables规则，可以查看iptables的帮助文件。

### Summary

本文介绍了如何将openstack环境中的虚拟机与public network连通。通过namespace和routing table，虚拟机不仅能在openstack环境内的不同网络间实现消息路由，还能与外部网络连通。

本文是这个系列文章的最后一篇。网络是opesntack最复杂的部分，是理解openstack的一个关键。阅读这四篇文章，对理解和分析openstack各种网络拓扑是很好的入门。使用我们提到的这些内容，可以更好的理解诸如Firewall as a service、Load Balance as a service、Metadata service这些网络概念。基本的学习方式是，进入namespace中，看究竟是如何利用Linux网络能力实现这些功能的。

我们在最开始说过，这些use case中我们只是使用了openstack众多网络配置方法的一种。我们的例子都是用了open vswitch 插件，可以独立于网络设备使用。通过与这里的例子对比，有助于分析其他的插件和功能。很多情况下，商业插件会使用open vswitch/bridges/namespace以及一些类似的方法和原理。

本系列文章的目的，在于让大多数用户了解oepnstack网络。文章中自下而上，使用一下简单的usecase，试着分析了openstack network 的整个结构以及如何工作的。与网上的其他一些资料不同，我们没有介绍各种openstack网络agent以及他们的功能，而是讲了他们做什么以及如何做的。下一步，你可以查阅这些资料，试着了解不同的agents是如何实现这些功能的。

全文结束。
