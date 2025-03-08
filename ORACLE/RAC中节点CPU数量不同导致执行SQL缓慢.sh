--由于主机CPU数量不同导致的执行SQL缓慢
在正常的情况下，RAC中的节点应该选择配置相同的机器，但是有时候也会出现不同。
LMS进程是根据CPU个数计算出来的。
所以当出现不一致的情况，就会导致缓慢，因此调整参数 gcs_server_process来手动调节。

SQL> show parameter gcs_server_process

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
gcs_server_processes                 integer     2                             lms进程的个数

