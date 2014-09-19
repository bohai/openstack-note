摘自https://major.io/2014/05/13/coreos-vs-project-atomic-a-review/。

【部署】
coreOS:
通过云上的镜像或者PXE部署。在云上可以使用cloud-config进行配置。
提供了etcd这个key-value系统，提供类似于zookeeper的能力。而且可以用于放置node信息。
提供fleet进行docker容器生命周期的管理。
container的自动迁移和loadbalance。

atomic：
atomic开始较晚，目前只提供了qemu/virtualbox的虚拟机镜像试用。
提供了geard工具部署容器。geard允许将多个容器关联起来为一个整体。并且可以跨多个host。


【管理】
coreOS：
提供了A/B系统用于更新。
没有提供python/perl/compiler，但是提供了一个“toolbox”的fedora容器。可以通过systemd-nspawn使用。
没有GUI。
提供了叫fleet的管理系统，进行docker容器的管理。

Atomic：
使用rpm-ostree（不使用yum)管理软件包。rpm-ostree类似于二进制版的git，可以提供软件的多个版本，并进行回退。
提供了叫cockpit的GUI组件用于管理docker容器。
Atomic的基础OS为fedora，并且可以自己构建。从fedora21开始，每个版本都会有一个fedora atomic发布。

【安全】
coreOS：
通过ssh key认证。
没有LDAP, Kerberos之类的认证。
没有Selinux，AppArmor和审计支持。

Atomic：
有selinux和svirt进行保护。
但是Cockpit目前还无法与selinux良好协作。

OStree参考：
http://www.slideshare.net/i_yudai/ostree-osgit

etcd：
是一个高可用的键值存储系统，主要用于共享配置和服务发现。etcd是由CoreOS开发并维护的，灵感来自于 ZooKeeper 和 Doozer，
它使用Go语言编写，并通过Raft一致性算法处理日志复制以保证强一致性。Raft是一个来自Stanford的新的一致性算法，适用于分布
式系统的日志复制，Raft通过选举的方式来实现一致性，在Raft中，任何一个节点都可能成为Leader。Google的容器集群管理系统
Kubernetes、开源PaaS平台Cloud Foundry和CoreOS的Fleet都广泛使用了etcd。

geard：
将多个容器关联起来作为一个整体管理。使用json描述。




