### 深入理解openstack网络架构(3)-----路由
前文中，我们学习了openstack网络几个基本组件，以及通过一些简单的use case解释网络如何连通的。这篇文章中，我们会继续通过一个稍微复杂（仍然相当基本）的use case（两个网络间路由）探索网络的设置。路由使用的组件与连通内部网络相同，使用另一个namespace创建一个隔离的container，允许subnet间的网络包中转。
记住我们在第一篇文章中所说的，这只是使用OVS插件的例子。这只是openstack的一中配置方式，还有很多插件使用不同的方式。

### Use case #4: Routing traffic between two isolated networks  
In a real world deployment we would like to create different networks for different purposes. We would also like to be able to connect those networks as needed. Since those two networks have different IP ranges we need a router to connect them. To explore this setup we will first create an additional network called net2 we will use 20.20.20.0/24 as its subnet. After creating the network we will launch an instance of Oracle Linux and connect it to net2. This is how this looks in the network topology tab from the OpenStack GUI:
现实中，我们会创建不同的网络用于不同的目的。我们也会需要把这些网络连接起来。因为两个网络在不同的IP段，我们需要router将他们连接起来。为了探索这种设置，我们
