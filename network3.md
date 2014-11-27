### 深入理解openstack网络架构(3)-----路由
In the previous posts we have seen the basic components of OpenStack networking and then described three simple use cases that explain how network connectivity is achieved. In this short post we will continue to explore networking setup through looking at a more sophisticated (but still pretty basic) use case of routing between two isolated networks. Routing uses the same basic components to achieve inter subnet connectivity and uses another namespace to create an isolated container to allow forwarding from one subnet to another.

Just to remind what we said in the first post, this is just an example using out of the box OVS plugin. This is only one of the options to use networking in OpenStack and there are many plugins that use different means.
