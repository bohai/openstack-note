### 组件一览
+ hacking        
一组flake8插件，用于静态检查。  
https://pypi.python.org/pypi/hacking 
+ coverage        
衡量python代码覆盖率的工具。可以单独执行/API方式或者以nose插件方式运行“nosetests --with-coverage”。  
https://nose.readthedocs.org/en/latest/plugins/cover.html  
+ discover   
测试用例发现。（2.7已经包含在unittest中，2.4需要backport) 主要在run_test.sh下使用。  
https://pypi.python.org/pypi/discover/0.4.0   
+ feedparser   
使用python进行parse RSS订阅内容主要在version API的测试中使用（versionAPI支持atom格式返回信息）
+ MySQL-python  
mysql接口的python实现
+ psycopg2  
postgresql接口的python实现
+ pylint       
对python进行静态分析、检查的工具
+ python-subunit   
subunit是测试结果的流协议。python-subunit是它的python实现。
+ sphinx      
文档生成工具（基于Restructed格式）
+ oslosphinx  
openstack对sphinx的扩展
+ testrepository  
测试结果的数据库。主要在覆盖率测试时使用。



### 2
