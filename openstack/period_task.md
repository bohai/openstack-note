openstack周期性任务浅析
------
我想从以下几个方面分析openstack的周期性任务实现。  
####  如何添加一个周期性任务  
在模块的manger.py中增加periodic_task装饰的周期性函数。  
每个调度周期运行一次：
```python
    @periodic_task.periodic_task
    def _instance_usage_audit(self, context):
        ...
```
指定运行间隔运行：
```python
    @periodic_task.periodic_task(
        spacing=CONF.running_deleted_instance_poll_interval)
    def _cleanup_running_deleted_instances(self, context):
        ...
```
####  周期性任务原理与实现  
+ decorator中做了什么？
对周期性任务的参数进行初始配置。
```python
def periodic_task(*args, **kwargs):
    def decorator(f):
        # Test for old style invocation
        if 'ticks_between_runs' in kwargs:
            raise InvalidPeriodicTaskArg(arg='ticks_between_runs')

        # Control if run at all
        f._periodic_task = True
        f._periodic_external_ok = kwargs.pop('external_process_ok', False)
        if f._periodic_external_ok and not CONF.run_external_periodic_tasks:
            f._periodic_enabled = False
        else:
            f._periodic_enabled = kwargs.pop('enabled', True)

        # Control frequency
        f._periodic_spacing = kwargs.pop('spacing', 0)
        f._periodic_immediate = kwargs.pop('run_immediately', False)
        if f._periodic_immediate:
            f._periodic_last_run = None
        else:
            f._periodic_last_run = timeutils.utcnow()
        return f
    ...
```
+ 周期性任务如何被管理？  
首先看类的继承关系：
```python
class ComputeManager(manager.Manager):
...

class Manager(base.Base, periodic_task.PeriodicTasks):
...

class PeriodicTasks(object):
...
```
周期性任务类只提供给了一个方法：运行周期性任务。
```python
class PeriodicTasks(object):
    __metaclass__ = _PeriodicTasksMeta

    def run_periodic_tasks(self, context, raise_on_error=False):
        ...
        for task_name, task in self._periodic_tasks:
            #执行所有周期性任务
    ...
```
由上我们可以看到，周期性任务类使用了元类_PeriodicTasksMeta。    
在元类中做了什么呢？    
我们可以看到在元类代码中，将所有周期性任务收集到_periodic_tasks列表中。  
我们在上边周期性任务类中可以看到，也使用了该列表进行任务调度。  
```python
#periodic_task.py中元类_PeriodicTasksMeta
    ...
       for value in cls.__dict__.values():
            if getattr(value, '_periodic_task', False):
                task = value
                name = task.__name__
                ...
                cls._periodic_tasks.append((name, task))
    ...
```
+ 周期性任务如何被触发调度？  
谁在调用run_periodic_tasks方法？  
service创建timer，定时触发周期性任务的调度。  
```python
#nova/service.py
    def start(self):
            ...
            self.tg.add_dynamic_timer(self.periodic_tasks,
                                     initial_delay=initial_delay,
                                     periodic_interval_max=
                                        self.periodic_interval_max)
            ...
            
    def periodic_tasks(self, raise_on_error=False):
        """Tasks to be run at a periodic interval."""
        ctxt = context.get_admin_context()
        return self.manager.periodic_tasks(ctxt, raise_on_error=raise_on_error)            
```
manager最终调用周期性任务类中的谁在调用run_periodic_tasks方法。   
```python
#nova/manager.py
    def periodic_tasks(self, context, raise_on_error=False):
        """Tasks to be run at a periodic interval."""
        return self.run_periodic_tasks(context, raise_on_error=raise_on_error)
```
