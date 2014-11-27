### 深入理解openstack网络架构(3)-----路由
前文中，我们学习了openstack网络几个基本组件，以及通过一些简单的use case解释网络如何连通的。这篇文章中，我们会继续通过一个稍微复杂（仍然相当基本）的use case（两个网络间路由）探索网络的设置。路由使用的组件与连通内部网络相同，使用另一个namespace创建一个隔离的container，允许subnet间的网络包中转。
记住我们在第一篇文章中所说的，这只是使用OVS插件的例子。这只是openstack的一中配置方式，还有很多插件使用不同的方式。

### Use case #4: Routing traffic between two isolated networks  
In a real world deployment we would like to create different networks for different purposes. We would also like to be able to connect those networks as needed. Since those two networks have different IP ranges we need a router to connect them. To explore this setup we will first create an additional network called net2 we will use 20.20.20.0/24 as its subnet. After creating the network we will launch an instance of Oracle Linux and connect it to net2. This is how this looks in the network topology tab from the OpenStack GUI:
现实中，我们会创建不同的网络用于不同的目的。我们也会需要把这些网络连接起来。因为两个网络在不同的IP段，我们需要router将他们连接起来。为了探索这种设置，我们创建另一个network（net2）并配置一个20.20.20.0/24的subnet。在创建这个network后，我们启动一个Oracle Linux的虚拟机，并连接到net2。下图是从OpenstackGUI上看到的网络拓扑图：  
![two-networks](https://blogs.oracle.com/ronen/resource/openstack-routing/two-networks.png)   
如果我们进一步探索发生了什么，我们会在openstack网络节点上看到另一个namespace，这个namespace用于为新创建的网络提供服务。现在我们有两个namespace，每个network一个。  
<pre><code>
# ip netns list
qdhcp-63b7fcf2-e921-4011-8da9-5fc2444b42dd
qdhcp-5f833617-6179-4797-b7c0-7d420d84040c
</code></pre>
可以通过nova net-list查看network的ID信息，或者使用UI查看网络信息。
<pre><code>
# nova net-list
+--------------------------------------+-------+------+
| ID                                   | Label | CIDR |
+--------------------------------------+-------+------+
| 5f833617-6179-4797-b7c0-7d420d84040c | net1  | None |
| 63b7fcf2-e921-4011-8da9-5fc2444b42dd | net2  | None |
+--------------------------------------+-------+------+
</code></pre>
我们新创建的network，net2有自己的namespace，这个namespace与net1是分离的。在namespace中，我们可以看到两个网络接口，一个local，一个是用于DHCP服务。
<pre><code>
# ip netns exec qdhcp-63b7fcf2-e921-4011-8da9-5fc2444b42dd ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
19: tap16630347-45: <BROADCAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN
    link/ether fa:16:3e:bd:94:42 brd ff:ff:ff:ff:ff:ff
    inet 20.20.20.3/24 brd 20.20.20.255 scope global tap16630347-45
    inet6 fe80::f816:3eff:febd:9442/64 scope link
       valid_lft forever preferred_lft forever
</code></pre>   
net1和net2两个network没有被联通，连接它们，我们需要创建一个router，通过router将两个network联通。Openstack Neutron向用户提供了创建router并将两个或多个network连接的能力。router其实只是一个额外的namespace。
使用Neutron创建router可以通过GUI或者命令行操作：
<pre><code>
# neutron router-create my-router
Created a new router:
+-----------------------+--------------------------------------+
| Field                 | Value                                |
+-----------------------+--------------------------------------+
| admin_state_up        | True                                 |
| external_gateway_info |                                      |
| id                    | fce64ebe-47f0-4846-b3af-9cf764f1ff11 |
| name                  | my-router                            |
| status                | ACTIVE                               |
| tenant_id             | 9796e5145ee546508939cd49ad59d51f     |
+-----------------------+--------------------------------------+
</code></pre>
现在我们将两个netwrok通过router连接： 

查看subnet的ID:
<pre><code>
# neutron subnet-list
+--------------------------------------+------+---------------+------------------------------------------------+
| id                                   | name | cidr          | allocation_pools                               |
+--------------------------------------+------+---------------+------------------------------------------------+
| 2d7a0a58-0674-439a-ad23-d6471aaae9bc |      | 10.10.10.0/24 | {"start": "10.10.10.2", "end": "10.10.10.254"} |
| 4a176b4e-a9b2-4bd8-a2e3-2dbe1aeaf890 |      | 20.20.20.0/24 | {"start": "20.20.20.2", "end": "20.20.20.254"} |
+--------------------------------------+------+---------------+------------------------------------------------+
</code></pre>
将subnet 10.10.10.0/24添加到router：
<pre><code>
# neutron router-interface-add fce64ebe-47f0-4846-b3af-9cf764f1ff11 subnet=2d7a0a58-0674-439a-ad23-d6471aaae9bc
Added interface 0b7b0b40-f952-41dd-ad74-2c15a063243a to router fce64ebe-47f0-4846-b3af-9cf764f1ff11.
</code></pre>
将subnet 20.20.20.0/24添加到router：

<pre><code>
# neutron router-interface-add fce64ebe-47f0-4846-b3af-9cf764f1ff11 subnet=4a176b4e-a9b2-4bd8-a2e3-2dbe1aeaf890
Added interface dc290da0-0aa4-4d96-9085-1f894cf5b160 to router fce64ebe-47f0-4846-b3af-9cf764f1ff11.
</code></pre>
此时，我们在查看网络拓扑会发现两个网络被router打通：
![networks-routed](https://blogs.oracle.com/ronen/resource/openstack-routing/networks-routed.png)
我们还可以发现两个网络接口连接到router，作为各自subnet的gateway。  

我们可以看到为router创建的namespace。  
<pre><code>
# ip netns list
qrouter-fce64ebe-47f0-4846-b3af-9cf764f1ff11
qdhcp-63b7fcf2-e921-4011-8da9-5fc2444b42dd
qdhcp-5f833617-6179-4797-b7c0-7d420d84040c
</code></pre>
我们进入namespace内部可以看到：  

<pre><code>
# ip netns exec qrouter-fce64ebe-47f0-4846-b3af-9cf764f1ff11 ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
20: qr-0b7b0b40-f9: <BROADCAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN
    link/ether fa:16:3e:82:47:a6 brd ff:ff:ff:ff:ff:ff
    inet 10.10.10.1/24 brd 10.10.10.255 scope global qr-0b7b0b40-f9
    inet6 fe80::f816:3eff:fe82:47a6/64 scope link
       valid_lft forever preferred_lft forever
21: qr-dc290da0-0a: <BROADCAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN
    link/ether fa:16:3e:c7:7c:9c brd ff:ff:ff:ff:ff:ff
    inet 20.20.20.1/24 brd 20.20.20.255 scope global qr-dc290da0-0a
    inet6 fe80::f816:3eff:fec7:7c9c/64 scope link
       valid_lft forever preferred_lft forever
</code></pre>
我们看到两个网络接口，“qr-dc290da0-0a“ 和 “qr-0b7b0b40-f9。这两个网络接口连接到OVS上，使用两个network/subnet的gateway IP。

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
        Port "qr-dc290da0-0a"
            tag: 2
            Interface "qr-dc290da0-0a"
                type: internal
        Port "tap26c9b807-7c"
            tag: 1
            Interface "tap26c9b807-7c"
                type: internal
        Port br-int
            Interface br-int
                type: internal
        Port "tap16630347-45"
            tag: 2
            Interface "tap16630347-45"
                type: internal
        Port "qr-0b7b0b40-f9"
            tag: 1
            Interface "qr-0b7b0b40-f9"
                type: internal
    ovs_version: "1.11.0"
</code></pre>

As we see those interfaces are connected to “br-int” and tagged with the VLAN corresponding to their respective networks. At this point we should be able to successfully ping the router namespace using the gateway address (20.20.20.1 in this case):


![ping-router](https://blogs.oracle.com/ronen/resource/openstack-routing/ping-router.png)
