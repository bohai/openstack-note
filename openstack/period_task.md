openstack周期性任务浅析
------
我想从以下几个方面分析openstack的周期性任务实现。  
####  如何添加一个周期性任务  
使用periodic_task装饰周期性函数。
```python
    @periodic_task.periodic_task
    def _instance_usage_audit(self, context):
```
####  周期性任务机制  
ff
####  周期性任务的当前实现的待改进点 
gg
