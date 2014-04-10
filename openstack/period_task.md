openstack周期性任务浅析
------
我想从以下几个方面分析openstack的周期性任务实现。  
####  如何添加一个周期性任务  
在模块的manger.py中增加periodic_task装饰的周期性函数。
每个调度周期运行一次：
```python
    @periodic_task.periodic_task
    def _instance_usage_audit(self, context):
```
指定运行间隔运行：
```python
    @periodic_task.periodic_task(
        spacing=CONF.running_deleted_instance_poll_interval)
    def _cleanup_running_deleted_instances(self, context):
```
####  周期性任务原理与实现  
ff
