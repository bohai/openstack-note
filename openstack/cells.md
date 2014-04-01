nova cells
----
cells为用户提供了一种以分布式风格Scacle Opensack的方式。用户不必使用复杂的数据库、消息总线cluster技术进行扩展。  
两者相比，cells更像是scale-out, 后者更像是scacle-up。cells目标是支持非常大的规模。  
***nova cells 目前仍是实验性质的***，笔者也未找到有生产部署的例子。  
### 配置过程
详细配置过程请参考[配置文档]：  
+ 修改nova.conf配置top-cell
```
[DEFAULT]
compute_api_class=nova.compute.cells_api.ComputeCellsAPI
...
[cells]
enable=True
name=api
```
+ 修改nova.conf配置child-cell
```
[DEFAULT]
# Disable quota checking in child cells. Let API cell do it exclusively.
quota_driver=nova.quota.NoopQuotaDriver
[cells]
enable=True
name=cell1
```
+ 配置数据库
```
in the API cell:
# nova-manage cell create --name=cell1 --cell_type=child --username=cell1_user
--password=cell1_passwd --hostname=10.0.1.10 --port=5673 --virtual_host=
cell1_vhost --woffset=1.0 --wscale=1.0
in the child cell: 
# nova-manage cell create --name=api --cell_type=parent --username=api1_user
--password=api1_passwd --hostname=10.0.0.10 --port=5672 --virtual_host=
api_vhost --woffset=1.0 --wscale=1.0
```
+ 配置scheduler

### 消息流
1. 如何进入cell的消息流程  
   从如上compute_api_class配置可以看出消息进入了nova.compute.cells_api.ComputeCellsAPI（继承nova.compute.api.API）。  
   非cell配置情况下，API消息会调用nova.compute.api.API。    
   ComputeCellsAPI处理例子： 
```python 
    @check_instance_cell
    def unrescue(self, context, instance):
        """Unrescue the given instance."""
        super(ComputeCellsAPI, self).unrescue(context, instance)
        self._cast_to_cells(context, instance, 'unrescue')
```
2. cell内消息路由过程
  ddd

### 参考
[配置文档]:http://docs.openstack.org/havana/config-reference/content/





