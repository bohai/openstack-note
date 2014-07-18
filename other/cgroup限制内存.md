Cgroup限制方法：
mkdir /cgroup/memory/test/
echo 50M > /cgroup/memory/test/memory.limit_in_bytes
echo 50M > /cgroup/memory/test/memory.memsw.limit_in_bytes
cgexec -g memory:test mongod -port 27017 --bind_ip 127.0.0.1 --dbpath /var/lib/mongo

我验证了下，通过cgroup限制后，当内存达到限额，进程会被kill。
[root@centos mongo]# cgexec -g memory:test mongod -port 27017 --bind_ip 127.0.0.1 --dbpath /var/lib/mongo
2014-07-18T23:20:53.228+0800 [initandlisten] MongoDB starting : pid=2529 port=27017 dbpath=/var/lib/mongo 64-bit host=centos
2014-07-18T23:20:53.228+0800 [initandlisten] db version v2.6.3
2014-07-18T23:20:53.228+0800 [initandlisten] git version: 255f67a66f9603c59380b2a389e386910bbb52cb
2014-07-18T23:20:53.228+0800 [initandlisten] build info: Linux build12.nj1.10gen.cc 2.6.32-431.3.1.el6.x86_64 #1 SMP Fri Jan 3 21:39:27 UTC 2014 x86_64 BOOST_LIB_VERSION=1_49
2014-07-18T23:20:53.228+0800 [initandlisten] allocator: tcmalloc
2014-07-18T23:20:53.228+0800 [initandlisten] options: { net: { bindIp: "127.0.0.1", port: 27017 }, storage: { dbPath: "/var/lib/mongo" } }
2014-07-18T23:20:53.304+0800 [initandlisten] journal dir=/var/lib/mongo/journal
2014-07-18T23:20:53.304+0800 [initandlisten] recover : no journal files present, no recovery needed
2014-07-18T23:20:53.374+0800 [initandlisten] waiting for connections on port 27017
2014-07-18T23:20:57.838+0800 [initandlisten] connection accepted from 127.0.0.1:36712 #1 (1 connection now open)
2014-07-18T23:21:15.077+0800 [initandlisten] connection accepted from 127.0.0.1:36713 #2 (2 connections now open)
2014-07-18T23:21:52.342+0800 [conn2] getmore test.my_collection cursorid:34538199491 ntoreturn:0 keyUpdates:0 numYields:39 locks(micros) r:121572 nreturned:95052 reslen:4194299 202ms
2014-07-18T23:21:53.376+0800 [clientcursormon] mem (MB) res:136 virt:12809
2014-07-18T23:21:53.376+0800 [clientcursormon]  mapped (incl journal view):12508
2014-07-18T23:21:53.376+0800 [clientcursormon]  connections:2
2014-07-18T23:21:56.790+0800 [conn2] getmore test.my_collection cursorid:34538199491 ntoreturn:0 keyUpdates:0 numYields:88 locks(micros) r:142113 nreturned:95595 reslen:4194301 244ms
Killed

数据查询：
[root@centos data]# cat mongotestList.py
import pymongo
import time

client = pymongo.MongoClient("localhost", 27017)
db = client.test
print db.name
print db.my_collection

for item in db.my_collection.find():
    print item

数据插入：
[root@centos data]# cat mongotest2.py
import pymongo
import time

client = pymongo.MongoClient("localhost", 27017)
db = client.test
print db.name
print db.my_collection

while True:
    db.my_collection.save({time.ctime(): time.time()})
