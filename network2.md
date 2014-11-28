### 深入理解openstack网络架构(2)  基本的use cases

在上一篇文章中，我们了解了几个网络组件，如openvswitch/network namespace/Linux bridges/veth pairs。这篇文章中，我们将用3个简单的use case，展示这些基本网络组件如何以工作从而实现openstack的SDN方案。    
在这些use case中，我们会了解整个网络配置和他们如何一起运行。use case如下：  

1. 创建网络——我们创建网络时，发生了什么。如何创建多个隔离的网络。  
2. 创建虚拟机——一旦我们有了网络，我们可以创建虚拟机并将其接入网络。   
3. 虚拟机的DHCP请求——opensack可以自动为虚拟机配置IP。通过openstack    neutron控制的DHCP服务完成。我们来了解这个服务如何运行，DHCP请求和回应是什么样子的？   

这篇文章中，我们会展示网络连接的原理，我们会了解网络包如何从A到B。我们先了解已经完成的网络配置是什么样子的？然后我们讨论这些网络配置是如何以及何时创建的？我个人认为，通过例子和具体实践看到真实的网络接口如何工作以及如何将他们连接起来是非常有价值的。然后，一切真相大白，我们知道网络连接如何工作，在后边的文章中，我将进一步解释neutron如何配置这些组件，从而提供这样的网络连接能力。

我推荐在你自己的环境上尝试这些例子或者使用Oracle Openstack Tech Preview。完全理解这些网络场景，对我们调查openstack环境中的网络问题非常有帮助。  

### Use case #1: Create Network
创建network的操作非常简单。我们可以使用GUI或者命令行完成。openstack的网络仅供创建该网络的租户使用。当然如果这个网络是“shared”，它也可以被其他所有租户使用。一个网络可以有多个subnets，但是为了演示目的和简单，我们仅为每一个network创建一个subnet。
通过命令行创建network： 
<pre><code>
# neutron net-create net1

Created a new network:

+---------------------------+--------------------------------------+

| Field                     | Value                                |

+---------------------------+--------------------------------------+

| admin_state_up            | True                                 |

| id                        | 5f833617-6179-4797-b7c0-7d420d84040c |

| name                      | net1                                 |

| provider:network_type     | vlan                                 |

| provider:physical_network | default                              |

| provider:segmentation_id  | 1000                                 |

| shared                    | False                                |

| status                    | ACTIVE                               |

| subnets                   |                                      |

| tenant_id                 | 9796e5145ee546508939cd49ad59d51f     |

+---------------------------+--------------------------------------+
</code></pre>
为这个network创建subnet:  
<pre><code>
# neutron subnet-create net1 10.10.10.0/24

Created a new subnet:

+------------------+------------------------------------------------+

| Field            | Value                                          |

+------------------+------------------------------------------------+

| allocation_pools | {"start": "10.10.10.2", "end": "10.10.10.254"} |

| cidr             | 10.10.10.0/24                                  |

| dns_nameservers  |                                                |

| enable_dhcp      | True                                           |

| gateway_ip       | 10.10.10.1                                     |

| host_routes      |                                                |

| id               | 2d7a0a58-0674-439a-ad23-d6471aaae9bc           |

| ip_version       | 4                                              |

| name             |                                                |

| network_id       | 5f833617-6179-4797-b7c0-7d420d84040c           |

| tenant_id        | 9796e5145ee546508939cd49ad59d51f               |

+------------------+------------------------------------------------+
</code></pre>

现在我们有了一个network和subnet，网络拓扑像这样：  
![horizon_network](https://blogs.oracle.com/ronen/resource/horizon-network.png)    

现在让我们深入看下到底发生了什么？在控制节点，我们一个新的namespace被创建：   
<pre><code>
# ip netns list

qdhcp-5f833617-6179-4797-b7c0-7d420d84040c
</code></pre>

这个namespace的名字是qdhcp-<network id> (参见上边),让我们深入namespace中看看有什么？   
<pre><code>
# ip netns exec qdhcp-5f833617-6179-4797-b7c0-7d420d84040c ip addr

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN

    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00

    inet 127.0.0.1/8 scope host lo

    inet6 ::1/128 scope host

       valid_lft forever preferred_lft forever

12: tap26c9b807-7c: <BROADCAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN

    link/ether fa:16:3e:1d:5c:81 brd ff:ff:ff:ff:ff:ff

    inet 10.10.10.3/24 brd 10.10.10.255 scope global tap26c9b807-7c

    inet6 fe80::f816:3eff:fe1d:5c81/64 scope link

       valid_lft forever preferred_lft forever
</code></pre>
我们发下在namespace下有两个网络接口，一个是loop设备，另一个叫“tap26c9b807-7c”。这个接口设置了IP地址10.10.10.3，他会接收dhcp请求（后边会讲）。接下来我们来跟踪下“tap26c9b807-7c”的网络连接性。我们从OVS上看下这个接口所连接的OVS网桥"br-int"。
<pre><code>
# ovs-vsctl show
8a069c7c-ea05-4375-93e2-b9fc9e4b3ca1
    Bridge "br-eth2"
        Port "br-eth2"
            Interface "br-eth2"
                type: internal
        Port "eth2"
            Interface "eth2"
        Port "phy-br-eth2"
            Interface "phy-br-eth2"
    Bridge br-ex
        Port br-ex
            Interface br-ex
                type: internal
    Bridge br-int
        Port "int-br-eth2"
            Interface "int-br-eth2"
        Port "tap26c9b807-7c"
            tag: 1
            Interface "tap26c9b807-7c"
                type: internal
        Port br-int
            Interface br-int
                type: internal
    ovs_version: "1.11.0"
</code></pre>
由上可知，veth pair的两端“int-br-eth2” 和 "phy-br-eth2"，这个veth pari连接两个OVS网桥"br-eth2"和"br-int"。上一篇文章中，我们解释过如何通过ethtool命令查看veth pairs的两端。就如下边的例子：
<pre><code>
# ethtool -S int-br-eth2
NIC statistics:
     peer_ifindex: 10
.
.
 
#ip link
.
.
10: phy-br-eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
.
.
</code></pre>
注意“phy-br-eth2”连接到网桥"br-eth2"，这个网桥的一个网口是物理网卡eth2。这意味着我们创建的网络创建了一个连接到了物理网卡eth2的namespace。eth2所在的虚拟机网络会连接所有的虚拟机的。

##### 关于网络隔离:  
Openstack支持创建多个隔离的网络，也可以使用多种机制完成网络间的彼此隔离。这些隔离机制包括VLANs/VxLANs/GRE tunnels，这个在我们部署openstack环境时配置。本文中我们选择了VLANs。当使用VLAN标签作为隔离机制，Neutron会从预定义好的VLAN池中选择一个VLAN标签，并分配给一个新创建的network。通过分配VLAN标签给network，Neutron允许在一个物理网卡上创建多个隔离的网络。与其他的平台的最大的区别是，用户不需要负责管理VLAN如何分配给networks。Neutron会负责管理分配VLAN标签，并负责回收。在我们的例子中，net1使用VLAN标签1000，这意味着连接到该网络的虚拟机，发出的包会被打上VLAN标签1000然后发送到物理网络中。对namespace也是同样的，如果我们希望namespace连接到某个特定网络，我们需要确保这个namespace发出的/接收的包被正确的打上了标签。

在上边的例子中，namespace中的网络接口“tap26c9b807-7c”被分配了VLAN标签1。如果我们从OVS观察下，会发现VLAN1会被改为VLAN1000，当包进入eth2所在的uxniji网络。反之亦然。我们通过OVS的dump-flows命令可以看到进入虚拟机网络的网络包在br-eth2上进行了VLAN标签的修改:
<pre><code>
#  ovs-ofctl dump-flows br-eth2
NXST_FLOW reply (xid=0x4):
 cookie=0x0, duration=18669.401s, table=0, n_packets=857, n_bytes=163350, idle_age=25, priority=4,in_port=2,dl_vlan=1 actions=mod_vlan_vid:1000,NORMAL
 cookie=0x0, duration=165108.226s, table=0, n_packets=14, n_bytes=1000, idle_age=5343, hard_age=65534, priority=2,in_port=2 actions=drop
 cookie=0x0, duration=165109.813s, table=0, n_packets=1671, n_bytes=213304, idle_age=25, hard_age=65534, priority=1 actions=NORMAL
</code></pre>
从网络接口到namespace我们看到VLAN标签的修改如下：  
<pre><code>
#  ovs-ofctl dump-flows br-int
NXST_FLOW reply (xid=0x4):
 cookie=0x0, duration=18690.876s, table=0, n_packets=1610, n_bytes=210752, idle_age=1, priority=3,in_port=1,dl_vlan=1000 actions=mod_vlan_vid:1,NORMAL
 cookie=0x0, duration=165130.01s, table=0, n_packets=75, n_bytes=3686, idle_age=4212, hard_age=65534, priority=2,in_port=1 actions=drop
 cookie=0x0, duration=165131.96s, table=0, n_packets=863, n_bytes=160727, idle_age=1, hard_age=65534, priority=1 actions=NORMAL
 </code></pre>
 
总之，当用户创建network，neutrong会创建一个namespace，这个namespace通过OVS连接到虚拟机网络。OVS还负责namespace与虚拟机网络之间VLAN标签的修改。现在，让我们看下创建虚拟机时，发生了什么？虚拟机是怎么连接到虚拟机网络的？   
### Use case #2: Launch a VM  
从Horizon或者命令行创建并启动一个虚拟机，下图是从Horzion创建的例子： 
![launch-instance](https://blogs.oracle.com/ronen/resource/launch-instance.png)    
挂载网络并启动虚拟机： 
![attach-network](https://blogs.oracle.com/ronen/resource/attach-network.png)  
一旦虚拟机启动并运行，我们发下nova支持给虚拟机绑定IP：  
<pre><code>
# nova list
+--------------------------------------+--------------+--------+------------+-------------+-----------------+
| ID                                   | Name         | Status | Task State | Power State | Networks        |
+--------------------------------------+--------------+--------+------------+-------------+-----------------+
| 3707ac87-4f5d-4349-b7ed-3a673f55e5e1 | Oracle Linux | ACTIVE | None       | Running     | net1=10.10.10.2 |
+--------------------------------------+--------------+--------+------------+-------------+-----------------+
</code></pre>
nova list命令显示虚拟机在运行中，并被分配了IP 10.10.10.2。我们通过虚拟机定义文件，查看下虚拟机与虚拟机网络之间的连接性。
虚拟机的配置文件在目录/var/lib/nova/instances/<instance-id>/下可以找到。通过查看虚拟机定义文件，libvirt.xml，我们可以看到虚拟机连接到网络接口“tap53903a95-82”，这个网络接口连接到了Linux网桥 “qbr53903a95-82”:
<pre><code>
<interface type="bridge">
      <mac address="fa:16:3e:fe:c7:87"/>
      <source bridge="qbr53903a95-82"/>
      <target dev="tap53903a95-82"/>
    </interface>
</code></pre>
通过brctl查看网桥信息如下：  
<pre><code>
# brctl show
bridge name     bridge id               STP enabled     interfaces
qbr53903a95-82          8000.7e7f3282b836       no              qvb53903a95-82
                                                        tap53903a95-82
</code></pre> 
 网桥有两个网络接口，一个连接到虚拟机(“tap53903a95-82 “)，另一个( “qvb53903a95-82”)连接到OVS网桥”br-int"。  
 
 <pre><code>
 # ovs-vsctl show
83c42f80-77e9-46c8-8560-7697d76de51c
    Bridge "br-eth2"
        Port "br-eth2"
            Interface "br-eth2"
                type: internal
        Port "eth2"
            Interface "eth2"
        Port "phy-br-eth2"
            Interface "phy-br-eth2"
    Bridge br-int
        Port br-int
            Interface br-int
                type: internal
        Port "int-br-eth2"
            Interface "int-br-eth2"
        Port "qvb53903a95-82"
            tag: 3
            Interface "qvb53903a95-82"
    ovs_version: "1.11.0"
 </code></pre>
 
我们之前看过，OVS网桥“br-int"连接到"br-eth2"，通过veth pair（int-br-eth2,phy-br-eth2 ），br-eth2连接到物理网卡eth2。整个流入如下：  
<pre><code>
VM  ->  tap53903a95-82 (virtual interface)  ->  qbr53903a95-82 (Linux bridge)  ->  qvb53903a95-82 (interface connected from Linux bridge to OVS bridge br-int)  ->  int-br-eth2 (veth one end)  ->  phy-br-eth2 (veth the other end)  ->  eth2 physical interface.
</code></pre>
与虚拟机相连的Linux bridage主要用于基于Iptables的安全组设置。安全组用于对虚拟机的网络隔离进行增强，由于iptables不能用于OVS网桥，因此我们使用了Linux网桥。后边我们会看到Linux网桥的规则设置。  

VLAN tags:我们在第一个use case中提到过，net1使用VLAN标签1000，通过OVS我们看到qvo41f1ebcf-7c使用VLAN标签3。VLAN标签从3到1000的转换在OVS中完成，通过br-eth2中实现。 
总结如下，虚拟机通过一组网络设备连入虚拟机网络。虚拟机和网络之间，VLAN标签被修改。

### Use case #3: Serving a DHCP request coming from the virtual machine   
之前的use case中，我们看到了一个叫dhcp-<some id>的namespace和虚拟机，两者最终连接到物理网络eth2。他们都会被打上VLAN标签1000。
我们看到该namespace中的网络接口使用IP 10.10.10.3。因为虚拟机和namespace彼此连接并在相同子网，因此可以ping到对方。如下图，虚拟机中网络接口被分配了IP 10.10.10.2，我们尝试ping namespace中的网络接口的IP:   
![vm-console](https://blogs.oracle.com/ronen/resource/vm-console.png)   

namespace与虚拟机之间连通，并且可以互相ping通，对于定位问题非常有用。我们可以从虚拟机ping通namespace，可以使用tcpdump或其他工具定位网络中断问题。

为了响应虚拟机的dhcp请求，Neutron使用了”dnsmasq“的Linux工具，这个工具是一个轻量的DNS、DHCP服务，更多的信息请查看（http://www.thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html）。我们可以在控制节点通过PS命令看到：
<pre><code>
dnsmasq --no-hosts --no-resolv --strict-order --bind-interfaces --interface=tap26c9b807-7c --except-interface=lo --pid-file=/var/lib/neutron/dhcp/5f833617-6179-4797-b7c0-7d420d84040c/pid --dhcp-hostsfile=/var/lib/neutron/dhcp/5f833617-6179-4797-b7c0-7d420d84040c/host --dhcp-optsfile=/var/lib/neutron/dhcp/5f833617-6179-4797-b7c0-7d420d84040c/opts --leasefile-ro --dhcp-range=tag0,10.10.10.0,static,120s --dhcp-lease-max=256 --conf-file= --domain=openstacklocal
</code></pre>
DHCP服务在namespace中连接到了一个tap接口（“--interface=tap26c9b807-7c”），从hosts文件我们可以看到：  
<pre><code>
# cat  /var/lib/neutron/dhcp/5f833617-6179-4797-b7c0-7d420d84040c/host
fa:16:3e:fe:c7:87,host-10-10-10-2.openstacklocal,10.10.10.2
</code></pre>
之前的console输出可以看到虚拟机MAC为fa:16:3e:fe:c7:87 。这个mac地址与IP 10.10.10.2 关联，当包含该MAC的DHCP请求到达，dnsmasq返回10.10.10.2。如果这个初始过程（可以重启网络服务触发）中从namespace中看，可以看到如下的DHCP请求：
<pre><code>
# ip netns exec qdhcp-5f833617-6179-4797-b7c0-7d420d84040c tcpdump -n
19:27:12.191280 IP 0.0.0.0.bootpc > 255.255.255.255.bootps: BOOTP/DHCP, Request from fa:16:3e:fe:c7:87, length 310
19:27:12.191666 IP 10.10.10.3.bootps > 10.10.10.2.bootpc: BOOTP/DHCP, Reply, length 325
</code></pre>
总之，DHCP服务由dnsmasq提供，这个服务由Neutron配置，监听在DHCP namespace中的网络接口上。Neutron还配置dnsmasq中的MAC/IP映射关系，所以当DHCP请求时会受到分配给它的IP。
### 总结  
本文，我们基于之前讲解的各种网络组建，看到三种use case下网络如何连通的。这些use cases对了解整个网络栈以及了解虚拟机/计算节点/DHCP namespace直接如何连通很有帮助。根据我们的探索，我们可以得出结论，我们启动虚拟机、虚拟机发出DHCP请求、虚拟机收到正确的IP、然后确信这个网络按照我们预想的工作。我们看到一个包经过一长串路径最终到达目的地，如果这一切成功，意味着这些组件功能正常。
下一篇文章中，我们会学习更复杂的neutron服务并探索他们如何工作。我们会看到更多的组件，但是大部分的原理概念都是相似的。
