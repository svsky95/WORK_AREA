##oracle脑裂问题分析##
一、心跳网络中断导致的脑裂
1、首先脑裂的出现，在另一个节点上会有CSS日志，提示：   /u01/app/11.2.0/grid/log/racnode01/cssd/ocssd.log
ssnmPollingThread: node racnode02 (2) at 50% heartbeat fatal, removal in 14.320 seconds
node 2 clean up, endp (0x6e0), init state 5, cur state 5

2、在故障节点中也能看到
node 1, racnode01, has a disk HB, but no network HB, DHB has rcfg

3、如果恢复后，故障节点，不能重新加入集群，建议重启整套的集群环境，让集群重新选举。