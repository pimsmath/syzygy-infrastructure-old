mcmaster (`/etc/modprobe.d/zfs.conf`)
-------------------------------------
```
options zfs zfs_arc_max=34359738368
options zfs zfs_arc_min=8589934592
options zfs zfs_prefetch_disable=1
```


ubc
---
`/etc/modprobe.d/zfs.conf`
```
options zfs zfs_arc_max=8589934592
options zfs zfs_arc_min=1073741824
options zfs zfs_prefetch_disable=1
options zfs zfs_arc_max=34359738368
```

`/etc/security/limits.d/20-nproc.conf`
```
# Default limit for number of user's processes to prevent
# accidental fork bombs.
# See rhbz #432903 for reasoning.

*       soft    nproc   131072
root    soft    nproc   unlimited
```

`/etc/security/limits.d/20-nfiles.conf`
```bash
*       soft    nofile  65536
```

Apache - this is a work in progress, but watch for exhaustion in
`/var/log/httpd/error_log`. As far as I can tell, it is related to settings in
the mpm_event module
```bash
# BEGIN ANSIBLE MANAGED BLOCK
<IfModule mpm_worker_module>
  ServerLimit 1024
  StartServers 10
  MinSpareThreads 128
  MaxSpareThreads 512
  ThreadLimit 64
  ThreadsPerChild 64
  MaxRequestWorkers 16384
</IfModule>
# END ANSIBLE MANAGED BLOCK
```
Graceful restarting of apache doesn't seem to be helpful here, you'll still hit
your head on limits during the changeover. I'm not sure what to do other than a
full restart of httpd. Also, it isn't clear if this is the actual root cause or
if some other limit (e.g. nfiles) is just showing up here.
