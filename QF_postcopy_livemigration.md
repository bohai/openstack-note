### 应用场景  
1. big guest的迁移  
2. 紧急疏散某个host上的虚拟机（比如可以预期的即将发生故障）  
3. 升级qemu（可以用unix socket，避免遇到网络故障）    

### matrix  

```shell
                          disk       RAM        internal snapshot
non-live                  yes (0)    yes (0)    yes
live, disk only           yes (1)    N/A        yes (2)
live, pre-copy            yes (3)    yes        no
live, post-copy           yes (4)    no         no
live, point-in-time       yes (5)    no         no

    (0) just stop VM while doing normal pre-copy migration
    (1) blockdev-snapshot-sync
    (2) blockdev-snapshot-internal-sync
    (3) block-stream
    (4) drive-mirror
    (5) drive-backup
```
