### 限速的方法
可以使用pv工具进行限速。
```shell
[root@controller ~(keystone_admin)]# dd if=/dev/sda | pv -L 3k |dd of=/home/bigfile
^C24kB 0:00:08 [3.02kB/s] [                    <=>                                                                                                         ]
记录了2+82 的读入
记录了50+0 的写出
25600字节(26 kB)已复制，8.3499 秒，3.1 kB/秒
```
