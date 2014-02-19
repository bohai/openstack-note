计划
------
0.  |openstack能力/bp调查  |  完成|
----|----------------------|------|
1.  |qemu/kvm能力验证      |完成|
2.  |openstack原型||
3.  |BP提交||
4.  |代码提交、review||

准备
------
###特性介绍  
qemu在1.5/1.6已经支持了raw和qcow2的[trim特性]。  
本文主要介绍在openstack中的实现。

###接口变化  
接口名：  
v2/​{tenant_id}​/servers/​{server_id}​/os-volume_attachments  
通过参数dict参数volumeAttachment传入是否开启trim。  

###代码流程  


###笔记
```xml
curl -i http://186.100.8.214:8774/v2/86196260e1694d0cbb5049cfba3883f8/servers/c62b5277-23cf-4af2-b6ae-15765e9341d1/os-volume_attachments -X GET -H "X-Auth-Project-Id: admin" -H "User-Agent: python-novaclient" -H "Accept: application/json" -H "X-Auth-Token: 2e3c783097fc4f07b2673f520f4d9962"
```

[trim特性]:QF_trim.md
[2]:https://wiki.openstack.org/wiki/BlockDeviceConfig
