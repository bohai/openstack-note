Openstack卷迁移限速
-----
为Openstack基于主机copy迁移卷增加限速能力。

计划
------
    |内容                  |  进度|
----|----------------------|------|
0.  |openstack能力/bp调查  |  完成|
1.  |当前实现以及限速方法调查      |  完成|
2.  |openstack实现原型||
3.  |BP提交||
4.  |代码提交、review||

过程
------
### 迁移命令  
```shell
[root@controller ~(keystone_admin)]# cinder help migrate
usage: cinder migrate [--force-host-copy <True|False>] <volume> <host>

Migrate the volume to the new host.

Positional arguments:
  <volume>              ID of the volume to migrate
  <host>                Destination host

Optional arguments:
  --force-host-copy <True|False>
                        Optional flag to force the use of the generic host-
                        based migration mechanism, bypassing driver
                        optimizations (Default=False).
```
支持两种类型的迁移：一种是基于Host的通用迁移方式，一种是基于driver的优化迁移方式。  
第二种方式可以利用存储本身的能力，实现更为高效的迁移。  
通过接口cinder卷的os-migrate_volume接口实现迁移功能。  

### 迁移处理流程  

> CLI/Web(1)-----rest req--->cinder API(2)-------->volume API(3)----rpc--->scheduler(4)--rpc-->volume manager(5)

1. CLI/Web产生卷的os-migrate_volume操作消息。
2. API层获取rest消息，提取消息内容
3. 过滤有快照的卷（不支持迁移），检查host有效性（可用，与源host不是一个）
4. 进行filter过滤确定host适合迁移
5. 对--force-host-copy为true的情况，使用_migrate_volume_generic函数。  
    对--force-host-copy为false的情况，使用cinder driver的migrate_volume接口。  

>_migrate_volume_generic函数处理过程：  

1. 在remote host上创建volume
2. copy volume  
    a. 卷被挂载在正在运行的虚拟机上：利用虚拟机存储迁移功能  
    b. 卷未被挂载在正在运行的虚拟机上：参考driver的copy_volume_data接口，内部为dd命令拷贝卷（volume_utils.copy_volume）  

### dd限速手段（利用pv工具）
可以使用pv工具进行限速。
```shell
[root@controller ~(keystone_admin)]# dd if=/dev/sda | pv -L 3k |dd of=/home/bigfile
^C24kB 0:00:08 [3.02kB/s] [                    <=>                                                                                                         ]
记录了2+82 的读入
记录了50+0 的写出
25600字节(26 kB)已复制，8.3499 秒，3.1 kB/秒
```

### python中多级管道的例子  
```python
[root@controller pipe]# more testpipe.py
import subprocess

if __name__=="__main__":
    ddpipe = subprocess.Popen( ["-c", "dd if=/dev/vda count=100 bs=512 | pv -L 3k | dd of=/home/bigfile" ],
        stdin= subprocess.PIPE, shell=True )
    ddpipe.communicate( "input data\n" )
    ddpipe.wait()
    
[root@controller pipe]# more testpipe2.py
import subprocess

if __name__=="__main__":
    child1 = subprocess.Popen(["dd", "if=/dev/vda", "bs=512", "count=100"], stdout=subprocess.PIPE)
    child2 = subprocess.Popen(["pv", "-L", "3k"], stdin=child1.stdout, stdout=subprocess.PIPE)
    child3 = subprocess.Popen(["dd", "of=/home/bigfile"], stdin=child2.stdout)
    out = child3.communicate()

```

备注：
1. 是否有跨存储类型的迁移?

