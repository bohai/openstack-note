openstack中的python高级用法
----
### metaclass
python的世界，一切皆是对象。类本身也是对象。  
对象是类的实例，类是元类的实例。  

通过元类，可以对对象进行负责的预操作。  
不过一般情况下，我们无需使用复杂的元类。  

我们通过以下两种方式实现类似的功能：
1. monkey patch
2. decorator（装饰器）

### monkey patch
可以理解为对函数的一种覆盖。  

### decorator
可以理解为在函数调用前的预处理。 

### 类方法

