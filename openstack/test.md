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
+ ***mock***       
对所测试的函数的外部依赖函数进行模拟替换。3.3以后已经是python标准库。
mock的实现原理也很简单，一般使用类似mokey patch的方式实现。  
+ ***mox***        
基于java的easymock提供的python mock对象框架（基本上已经停止维护）   
Mox的执行流程：
	* Create mock (in record mode)
	* Set up expectations
	* Put mock into replay mode
	* Run test
	* Verify expected interactions with the mock occurred
mox与mock功能类似，都是用来做函数或者类的mock。

```
Mock方法和属性：
>>> # Mock
>>> my_mock = mock.Mock()
>>> my_mock.some_method.return_value = "calculated value"
>>> my_mock.some_attribute = "value"
>>> assertEqual("calculated value", my_mock.some_method())
>>> assertEqual("value", my_mock.some_attribute)

>>> # Mox
>>> my_mock = mox.MockAnything()
>>> my_mock.some_method().AndReturn("calculated value")
'calculated value'
>>> my_mock.some_attribute = "value"
>>> mox.Replay(my_mock)
>>> assertEqual("calculated value", my_mock.some_method())
>>> assertEqual("value", my_mock.some_attribute)

部分mock（对已有对象的某个方法进行mock）：
>>> # Mock
>>> SomeObject.some_method = mock.Mock(return_value='value')
>>> assertEqual("value", SomeObject.some_method())

>>> # Mox
>>> my_mock = mox.MockObject(SomeObject)
>>> my_mock.some_method().AndReturn("value")
'value'
>>> mox.Replay(my_mock)
>>> assertEqual("value", my_mock.some_method())
>>> mox.Verify(my_mock)

抛出异常：
>>> # Mock
>>> my_mock = mock.Mock()
>>> my_mock.some_method.side_effect = SomeException("message")
>>> assertRaises(SomeException, my_mock.some_method)

>>> # Mox
>>> my_mock = mox.MockAnything()
>>> my_mock.some_method().AndRaise(SomeException("message"))
>>> mox.Replay(my_mock)
>>> assertRaises(SomeException, my_mock.some_method)
>>> mox.Verify(my_mock)

```
+ ***fixtures***  
翻译为“夹具”，顾名思义提供了状态重用等的抽象机制。
```
---------------myfixture.py-----------------------
import testtools
import unittest
import fixtures
class NoddyFixture(fixtures.Fixture):
    def setUp(self):
        super(NoddyFixture, self).setUp()
        self.frobnozzle = 42
        self.addCleanup(delattr, self, 'frobnozzle')


class NoddyTest(testtools.TestCase, fixtures.TestWithFixtures):
    def test_example(self):
        fixture = self.useFixture(NoddyFixture())
        self.assertEqual(42, fixture.frobnozzle)

result = unittest.TestResult()
_ = NoddyTest('test_example').run(result)
print (result.wasSuccessful())

-----------------运行结果------------------------
[root@centoo65 data]# python myfixtures.py
True
 
-----------常用fixture-------------------------
>>> import fixtures
>>> a = fixtures.TempDir()
>>> a.setUp()
>>> print a.path
/tmp/tmpWB8EmF
>>> quit()
----------------------------------------------
其他参见PolicyFixture
```
+ ***testtools***   
对python标准单元测试框架的扩展。为什么使用？
  + 更好的断言    比如支持assertThat扩展
  + 更详细的debug信息  比如支持addDetails的信息
  + 扩展的同时保持兼容性  
  + python多版本的兼容性
+ ***tox***   
通用的虚拟环境管理和测试命令行工具。    
配置可以看工程下的tox.ini文件。tox.ini可以通过tox-quickstart生成。     
命令执行，如：“tox -e py26", "tox -e pep8"   
执行单元测试的时候，顺便生成单元测试报告，并检查测试覆盖率，并生成覆盖率报告。直接执行tox是不行的，只能进行单元测试，需要给tox增加扩展参数，如下：tox -- --cover-erase -- --with-coverage -- --cover-html


### 类说明
test.py
test.TestCase继承于testtools.TestCase。
test.NoDBTestCase继承于test.TestCase。

test.TestCase中大量使用了fixture对环境进行初始化。（比如DB，Policy等）
### 实例


