### 前言   
openstack网络功能强大同时也相对更复杂。本系列文章通过Oracle OpenStack Tech
Preview介绍openstack的配置，通过各种场景和例子说明openstack各种不同的网络组件。
本文的目的在于提供openstack网络架构的全景图并展示各个模块是如何一起协作的。这对openstack的初学者以及希望理解openstack网络原理的人会非常有帮助。
首先，我们先讲解下一些基础并举例说明。

根据最新的icehouse版用户调查，基于open vswitch插件的Neutron在生产环境和POC环境都被广泛使用，所以在这个系列的文章中我们主要分析这种openstack网络的配置。当然，我们知道openstack网络支持很多种配置，尽管neutron+open vswitch是最常用的配置，但是我们从未说它是最好或者最高效的一种方式。Neutron+open vswitch仅仅是一个例子，对任何希望理解openstack网络的人是一个很好的切入点。即使你打算使用其他类型的网络配置比如使用不同的neutron插件或者根本不使用neutron，这篇文章对你理解openstack网络仍是一个很好的开始。

我们在例子中使用的配置是Oracle OpenStack Tech Preview所提供的一种配置。安装它非常简单，并且它是一个很好的参考。在这种配置中，我们在所有服务器上使用eth2作为虚拟机的网络，所有虚拟机流量使用这个网卡。Oracle OpenStack Tech Preview使用VLAN进行L2隔离，进而提供租户和网络隔离，下图展示了我们如何进行配置和部署：


第一篇文章会略长，我们将聚焦于openstack网络的一些基本概念。我们将讨论open vswitch、network namespaces、linux bridge、veth pairs等几个组件。注意这里不打算全面介绍这些组件，只是为了理解openstack网络架构。可以通过网络上的其他资源进一步了解这些组件。

### Open vSwitch (OVS)   
在Oracle OpenStack Tech Preview中用于连接虚拟机和物理网口（如上例中的eth2)，就像上边部署图所示。OVS包含bridages和ports，OVS bridges不同于与linux bridge（使用brctl命令创建）。让我们先看下OVS的结构，使用如下命令：
<pre><code>
# ovs-vsctl show
7ec51567-ab42-49e8-906d-b854309c9edf
    Bridge br-int
        Port br-int
            Interface br-int
                type: internal
        Port "int-br-eth2"
            Interface "int-br-eth2"
    Bridge "br-eth2"
        Port "br-eth2"
            Interface "br-eth2"
                type: internal
        Port "eth2"
            Interface "eth2"
        Port "phy-br-eth2"
            Interface "phy-br-eth2"
ovs_version: "1.11.0"
</code></pre>
我们看到标准的部署在compute node上的OVS，拥有两个网桥，每个有若干相关联的port。上边的例子是在一个没有任何虚拟机的计算节点上。我们可以看到eth2连接到个叫br-eth2的网桥上，我们还看到两个叫“int-br-eth2"和”phy-br-eth2“的port，事实上是一个veth pair，作为虚拟网线连接两个bridages。我们会在后边讨论veth paris。

当我们创建一个虚拟机，br-int网桥上会创建一个port，这个port最终连接到虚拟机（我们会在后边讨论这个连接）。这里是启动一个虚拟机后的OVS结构：
<pre><code>
# ovs-vsctl show
efd98c87-dc62-422d-8f73-a68c2a14e73d
    Bridge br-int
        Port "int-br-eth2"
            Interface "int-br-eth2"
        Port br-int
            Interface br-int
                type: internal
        Port "qvocb64ea96-9f"
            tag: 1
            Interface "qvocb64ea96-9f"
    Bridge "br-eth2"
        Port "phy-br-eth2"
            Interface "phy-br-eth2"
        Port "br-eth2"
            Interface "br-eth2"
                type: internal
        Port "eth2"
            Interface "eth2"
ovs_version: "1.11.0"
</code></pre>
”br-int“网桥现在有了一个新的port"qvocb64ea96-9f" 连接VM，并且被标记为vlan1。虚拟机的每个网卡都需要对应在"br-int”网桥上创建一个port。

OVS中另一个有用的命令是dump-flows，以下为例子：  
# ovs-ofctl dump-flows br-int
NXST_FLOW reply (xid=0x4):
cookie=0x0, duration=735.544s, table=0, n_packets=70, n_bytes=9976,idle_age=17, priority=3,in_port=1,dl_vlan=1000 actions=mod_vlan_vid:1,NORMAL
cookie=0x0, duration=76679.786s, table=0, n_packets=0, n_bytes=0,idle_age=65534, hard_age=65534, priority=2,in_port=1 actions=drop
cookie=0x0, duration=76681.36s, table=0, n_packets=68, n_bytes=7950,idle_age=17, hard_age=65534, priority=1 actions=NORMAL
如上所述，VM相连的port使用了Vlan tag 1。然后虚拟机网络（eth2)上的port使用tag1000。OVS会修改VM和物理网口间所有package的vlan。在openstack中，OVS
 agent 控制open vswitch中的flows，用户不需要进行操作。如果你想了解更多的如何控制open vswitch中的流，可以参考http://openvswitch.org中对ovs-ofctl的描述。

Network Namespaces (netns)
网络namespace是linux上一个很cool的特性，它的用途很多。在openstack网络中被广泛使用。网络namespace是拥有独立的网络配置隔离容器，并且该网络不能被其他名字空间看到。网络名字空间可以被用于封装特殊的网络功能或者在对网络服务隔离的同时完成一个复杂的网络设置。在Oracle OpenStack Tech Preview中我们使用最新的R3企业版内核，该内核提供给了对netns的完整支持。

通过如下例子我们展示如何使用netns命令控制网络namespaces。
定义一个新的namespace:
# ip netns add my-ns
# ip netns list
my-ns

我们说过namespace是一个隔离的容器，我们可以在namspace中进行各种操作，比如ifconfig命令。

# ip netns exec my-ns ifconfig -a
lo        Link encap:Local Loopback
          LOOPBACK  MTU:16436 Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:0
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
我们可以在namespace中运行任何命令，比如对debug非常有用的tcddump命令，我们使用ping、ssh、iptables命令。
连接namespace和外部：
连接到namespace和namespace直接连接的方式有很多，我们主要聚集在openstack中使用的方法。openstack使用了OVS和网络namespace的组合。OVS定义接口，然后我们将这些接口加入namespace中。
# ip netns exec my-ns ifconfig -a
lo        Link encap:Local Loopback
          LOOPBACK  MTU:65536 Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:0
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)

my-port   Link encap:Ethernet HWaddr 22:04:45:E2:85:21
          BROADCAST  MTU:1500 Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:0
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
现在我们可以增加更多的ports到OVS bridge，并且连接到其他namespace或者其他设备比如物理网卡。Neutron使用网络namespace来实现网络服务，如DHCP、routing、gateway、firewall、load balance等。下一篇文章我们会讨论更多细节 。

Linux bridge and veth pairs

Veth pairs are used extensively throughout the network setup in OpenStack and are also a good tool to debug a network problem. Veth pairs are simply a virtual wire and so veths always come in pairs. Typically one side of the veth pair will connect to a bridge and the other side to another bridge or simply left as a usable interface.
In this example we will create some veth pairs, connect them to bridges and test connectivity. This example is using regular Linux server and not an OpenStack node:
Creating a veth pair, note that we define names for both ends:

Linux bridge用于连接OVS port和虚拟机。ports负责连通OVS bridge和linux bridge或者两者与虚拟机。linux bridage主要用于安全组增强。安全组通过iptables实现，iptables只能用于linux bridage而非OVS bridage。


https://blogs.oracle.com/ronen/entry/diving_into_openstack_network_architecture
