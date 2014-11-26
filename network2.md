在上一篇文章中，我们了解了几个网络组件，如openvswitch/network namespace/Linux bridges/veth pairs。这篇文章中，我们将用3个简单的网络场景，展示这些基本网络组件如何以工作从而实现openstack的SDN方案。在这些网络场景中，我们会了解整个网络配置和他们如何一起运行。网络场景如下：  

1. 创建网络——我们创建网络时，发生了什么。如何创建多个隔离的网络。  
2. 创建虚拟机——一旦我们有了网络，我们可以创建虚拟机并将其接入网络。   
3. 虚拟机的DHCP请求——opensack可以自动为虚拟机配置IP。通过openstack    neutron控制的DHCP服务完成。我们来了解这个服务如何运行，DHCP请求和回应是什么样子的？   

这篇文章中，我们会展示网络连接的原理，我们会了解网络包如何从A到B。我们先了解已经完成的网络配置是什么样子的？然后我们讨论这些网络配置是如何以及何时创建的？我个人认为，通过例子和具体实践看到真实的网络接口如何工作以及如何将他们连接起来是非常有价值的。然后，一切真相大白，我们知道网络连接如何工作，在后边的文章中，我将进一步解释neutron如何配置这些组件，从而提供这样的网络连接能力。

我推荐在你自己的部署上尝试这些例子或者使用Oracle Openstack Tech Preview。完全理解这些网络场景，对我们调查openstack环境中的网络问题非常有帮助。  

### Use case #1: Create Network
创建网络的操作非常简单。我们可以使用GUI或者命令行完成。openstack的网络仅供创建该网络的租户使用。当然如果这个网络是“shared”，它也可以被其他所有租户使用。一个网络可以有多个subnets，但是为了演示目的和简单，我们仅为每一个network创建一个subnet。
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
