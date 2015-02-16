以下内容基于juno版openstack代码。  
### 安全组     
安全组用来对虚拟机的网络设置IP过滤规则。安全组隶属于project，project的成员可以编辑默认安全组规则以及增加新的工作集。  
所有的project都有一个default安全组，默认组织一切流入流量。

nova.conf有一个allow_same_net_traffic 参数，若设置为true，同一subnet中的所有虚拟机可以互相通信。
这意味着，在flat网络中所有project的虚拟机可以互相通信；在vlan网络中，同一project的虚拟机互相通信。

安全组的目的在于基于安全因素对虚拟机的网络流入流出进行控制。
### 安全组操作  

### 安全组原理与代码分析    



参考：  
RDO网站上将openstack网络细节的，讲的不错。  
https://openstack.redhat.com/Networking_in_too_much_detail   
