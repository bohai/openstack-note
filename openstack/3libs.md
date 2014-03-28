### six
提供python2/python3的兼容适配层。 
+ six用法
```python
@add_metaclass(Meta)
class MyClass(object):
    pass
```
+ 对应python3
```python
class MyClass(object, metaclass=Meta):
    pass
```
+ 对应python2
```python
class MyClass(object):
    __metaclass__ = MyMeta
```
