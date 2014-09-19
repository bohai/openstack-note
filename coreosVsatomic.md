coreOS与atomic对比

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
Atomic的基础OS为fedora，并且可以自己构建。

【安全】
coreOS：
通过ssh key认证。
没有LDAP, Kerberos之类的认证。
没有Selinux，AppArmor和审计支持。

Atomic：
有selinux和svirt进行保护。
但是Cockpit目前还无法与selinux良好协作。

