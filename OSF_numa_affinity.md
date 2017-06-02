# 什么是NUMA
NUMA全称是Non-Uniform Memory Access。在NUMA中每个CPU都会分配Local memory，CPU和local memory组成NUMA node。
CPU访问local memory，速度会很快；而访问其他node上的memory（这个称作访问remote memory）速度会比较慢，延迟无法预知。


# 什么是vNUMA

![numa](https://657cea1304d5d92ee105-33ee89321dddef28209b83f19f06774f.ssl.cf1.rackcdn.com/NUMA1-54bd8529f54ce4c5774b601f90de303a9e2629f1c10ccd593add3a17fe0fd83e.png)
