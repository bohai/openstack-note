review技巧
-----
### 可参考资料 
+ 代码风格  
http://docs.openstack.org/developer/hacking/  
+ API规则  
https://wiki.openstack.org/wiki/APIChangeGuidelines  

### 具体样例  
+ 无效log/错误的log  
比如某个log已经失效，或者完全不对  
+ API使用错误  
对某个API的返回使用错误。  
使用旧的，废弃的API。   
+ 逻辑表达式（性能最优）   
优先判断不等。  
```python
if (fixedip.virtual_interface.address not in macs) and \
   (fixedip.virtual_interface.address != vif_address):
```
