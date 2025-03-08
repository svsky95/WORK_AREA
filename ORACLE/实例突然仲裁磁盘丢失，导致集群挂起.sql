##问题描述
实例1出现：进程数满导致sqlplus登录不了，之后杀掉了很多进程，登录进去后，发现执行SQL命令。
实例2出现：出现ssh主机无法登录，做不了任何的操作。
##故障问题分析
节点2 在 04:59:02.003时间点，出现了磁盘丢失的情况，导致集群剔除掉了实例2。
经过平台组分析，是由于solaris主机的管理域（管理下面所有分片节点）自动重启导致的。
##节点1 OCSS日志
2020-06-16 04:59:02.003: [    CSSD][42]clssgmMbrKillThread: Member kill request complete.
2020-06-16 04:59:02.003: [    CSSD][42]clssgmMbrKillSendEvent: Missing answers or immediate escalation: Req member 0 Req node 1 Number of answers expected 0 Number of answers outstanding 1 
2020-06-16 04:59:02.003: [    CSSD][42]clssgmQueueGrockEvent: groupName(DBSNGSNFDB) count(2) master(0) event(11), incarn 0, mbrc 0, to member 0, events 0x68, state 0x0
2020-06-16 04:59:02.003: [    CSSD][42]clssgmMbrKillEsc: Escalating node 2 Member request 0x00000002 Member success 0x00000000 Member failure 0x00000000 Number left to kill 1 
2020-06-16 04:59:02.003: [    CSSD][42]clssnmMarkNodeForRemoval: node 2, dzswjnfdb2 marked for removal
2020-06-16 04:59:02.003: [    CSSD][42]clssnmKillNode: node 2 (dzswjnfdb2) kill initiated
2020-06-16 04:59:02.003: [    CSSD][42]clssgmMbrKillThread: Exiting
2020-06-16 04:59:02.003: [    CSSD][23]clssnmDiscHelper: dzswjnfdb2, node(2) connection failed, endp (204c5420), probe(0), ninf->endp 204c5420
2020-06-16 04:59:02.003: [    CSSD][23]clssnmDiscHelper: node 2 clean up, endp (204c5420), init state 5, cur state 5
2020-06-16 04:59:02.003: [GIPCXCPT][23] gipcInternalDissociate: obj 10898dd50 [00000000204c5420] { gipcEndpoint : localAddr 'gipcha://dzswjnfdb1:nm2_dzswjnfcluster/a25f-b3eb-696a-928', remoteAddr 'gipcha://dzswjnfdb2:a038-b830-1634-21d', numPend 1, numReady 0, numDone 0, numDead 0, numTransfer 0, objFlags 0x0, pidPeer 0, readyRef 0, ready 1, wobj 1036833f0, sendp 0flags 0x138606, usrFlags 0x0 } not associated with any container, ret gipcretFail (1)
2020-06-16 04:59:02.003: [GIPCXCPT][23] gipcDissociateF [clssnmDiscHelper : clssnm.c : 3485]: EXCEPTION[ ret gipcretFail (1) ]  failed to dissociate obj 10898dd50 [00000000204c5420] { gipcEndpoint : localAddr 'gipcha://dzswjnfdb1:nm2_dzswjnfcluster/a25f-b3eb-696a-928', remoteAddr 'gipcha://dzswjnfdb2:a038-b830-1634-21d', numPend 1, numReady 0, numDone 0, numDead 0, numTransfer 0, objFlags 0x0, pidPeer 0, readyRef 0, ready 1, wobj 1036833f0, sendp 0flags 0x138606, usrFlags 0x0 }, flags 0x0
2020-06-16 04:59:02.004: [    CSSD][25]clssnmDoSyncUpdate: Initiating sync 472333840
2020-06-16 04:59:02.004: [    CSSD][25]clssscCompareSwapEventValue: changed NMReconfigInProgress  val 1, from -1, changes 25
2020-06-16 04:59:02.004: [    CSSD][25]clssnmDoSyncUpdate: local disk timeout set to 27000 ms, remote disk timeout set to 27000
2020-06-16 04:59:02.004: [    CSSD][25]clssnmDoSyncUpdate: new values for local disk timeout and remote disk timeout will take effect when the sync is completed.
2020-06-16 04:59:02.004: [    CSSD][25]clssnmDoSyncUpdate: Starting cluster reconfig with incarnation 472333840
2020-06-16 04:59:02.004: [    CSSD][25]clssnmSetupAckWait: Ack message type (11) 
2020-06-16 04:59:02.004: [    CSSD][25]clssnmSetupAckWait: node(1) is ALIVE
2020-06-16 04:59:02.004: [    CSSD][25]clssnmSendSync: syncSeqNo(472333840), indicating EXADATA fence initialization complete
2020-06-16 04:59:02.004: [    CSSD][25]List of nodes that have ACKed my sync: NULL
2020-06-16 04:59:02.004: [    CSSD][25]clssnmSendSync: syncSeqNo(472333840)
2020-06-16 04:59:02.004: [    CSSD][25]clssnmWaitForAcks: Ack message type(11), ackCount(1)
2020-06-16 04:59:02.004: [    CSSD][26]clssnmDiscEndp: gipcDestroy 204c5420 
2020-06-16 04:59:02.004: [    CSSD][26]clssnmHandleSync: Node dzswjnfdb1, number 1, is EXADATA fence capable
2020-06-16 04:59:02.004: [    CSSD][26]clssscUpdateEventValue: NMReconfigInProgress  val 1, changes 26
2020-06-16 04:59:02.004: [    CSSD][26]clssnmHandleSync: local disk timeout set to 27000 ms, remote disk timeout set to 27000
2020-06-16 04:59:02.004: [    CSSD][26]clssnmHandleSync: initleader 1 newleader 1
2020-06-16 04:59:02.004: [    CSSD][26]clssnmQueueClientEvent:  Sending Event(2), type 2, incarn 472333839
2020-06-16 04:59:02.004: [    CSSD][26]clssnmQueueClientEvent: Node[1] state = 3, birth = 472333832, unique = 1576839012
2020-06-16 04:59:02.004: [    CSSD][26]clssnmQueueClientEvent: Node[2] state = 5, birth = 472333839, unique = 1587531535
2020-06-16 04:59:02.004: [    CSSD][26]clssnmHandleSync: Acknowledging sync: src[1] srcName[dzswjnfdb1] seq[41] sync[472333840]
2020-06-16 04:59:02.004: [    CSSD][26]clssnmSendAck: node 1, dzswjnfdb1, syncSeqNo(472333840) type(11)
2020-06-16 04:59:02.004: [    CSSD][1]clssgmStartNMMon: node 1 active, birth 472333832
2020-06-16 04:59:02.004: [    CSSD][1]clssgmStartNMMon: node 2 active, birth 472333839
2020-06-16 04:59:02.004: [    CSSD][26]clssnmHandleAck: Received ack type 11 from node dzswjnfdb1, number 1, with seq 0 for sync 472333840, waiting for 0 acks
2020-06-16 04:59:02.004: [    CSSD][1]NMEVENT_SUSPEND [00][00][00][06]
2020-06-16 04:59:02.004: [    CSSD][25]clssnmSendSync: syncSeqNo(472333840), indicating EXADATA fence initialization complete
2020-06-16 04:59:02.004: [    CSSD][25]List of nodes that have ACKed my sync: 1
2020-06-16 04:59:02.004: [    CSSD][1]clssgmCompareSwapEventValue: changed CmInfo State  val 5, from 11, changes 81
2020-06-16 04:59:02.004: [    CSSD][1]clssgmSuspendAllGrocks: Issue SUSPEND
2020-06-16 04:59:02.004: [    CSSD][25]clssnmWaitForAcks: done, syncseq(472333840), msg type(11)
2020-06-16 04:59:02.004: [    CSSD][25]clssnmSetMinMaxVersion:node1  product/protocol (11.2/1.4)
2020-06-16 04:59:02.004: [    CSSD][25]clssnmSetMinMaxVersion: properties common to all nodes: 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
2020-06-16 04:59:02.004: [    CSSD][25]clssnmSetMinMaxVersion: min product/protocol (11.2/1.4)
2020-06-16 04:59:02.004: [    CSSD][25]clssnmSetMinMaxVersion: max product/protocol (11.2/1.4)
2020-06-16 04:59:02.004: [    CSSD][25]clssnmNeedConfReq: No configuration to change
2020-06-16 04:59:02.004: [    CSSD][25]clssnmDoSyncUpdate: Terminating node 2, dzswjnfdb2, misstime(140) state(5)
2020-06-16 04:59:02.004: [    CSSD][25]clssnmDoSyncUpdate: Wait for 0 vote ack(s)
2020-06-16 04:59:02.004: [    CSSD][25]clssnmCheckDskInfo: Checking disk info...
2020-06-16 04:59:02.004: [    CSSD][25]clssnmRemove: Start
2020-06-16 04:59:02.004: [    CSSD][25](:CSSNM00007:)clssnmrRemoveNode: Evicting node 2, dzswjnfdb2, from the cluster in incarnation 472333840, node birth incarnation 472333839, death incarnation 472333840, stateflags 0x23e000 uniqueness value 1587531535
2020-06-16 04:59:02.004: [    CSSD][1]clssgmQueueGrockEvent: groupName(IG+ASMSYS$USERS) count(2) master(1) event(2), incarn 8, mbrc 2, to member 1, events 0x0, state 0x0
2020-06-16 04:59:02.004: [    CSSD][1]clssgmQueueGrockEvent: groupName(CLSN.AQPROC.sngsnfdb.MASTER) count(2) master(1) event(2), incarn 2, mbrc 2, to member 1, events 0xa0, state 0x0
2020-06-16 04:59:02.004: [ default][25]kgzf_gen_node_reid2: generated reid cid=2fc93f4a341acf9eff5104845c36bc95,icin=472333832,nmn=2,lnid=472333839,gid=0,gin=0,gmn=0,umemid=0,opid=0,opsn=0,lvl=node hdr=0xfece0100

2020-06-16 04:59:02.004: [    CSSD][25]clssnmrFenceSage: Fenced node dzswjnfdb2, number 2, with EXADATA, handle 0
2020-06-16 04:59:02.004: [    CSSD][25]clssnmSendShutdown: req to node 2, kill time 3969073350
2020-06-16 04:59:02.004: [    CSSD][25]clssnmsendmsg: not connected to node 2

2020-06-16 04:59:02.004: [    CSSD][25]clssnmSendShutdown: Send to node 2 failed
2020-06-16 04:59:02.004: [    CSSD][1]clssgmQueueGrockEvent: groupName(crs_version) count(3) master(0) event(2), incarn 9, mbrc 3, to member 0, events 0x20, state 0x0
2020-06-16 04:59:02.004: [    CSSD][25]clssnmWaitOnEvictions: Start
2020-06-16 04:59:02.004: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254318, 2807418702, 4720680), seedhbimpd TRUE
2020-06-16 04:59:02.004: [    CSSD][1]clssgmQueueGrockEvent: groupName(crs_version) count(3) master(0) event(2), incarn 9, mbrc 3, to member 1, events 0x0, state 0x0
2020-06-16 04:59:02.004: [    CSSD][1]clssgmQueueGrockEvent: groupName(CRF-) count(4) master(0) event(2), incarn 20, mbrc 4, to member 0, events 0x38, state 0x0
2020-06-16 04:59:02.004: [    CSSD][1]clssgmQueueGrockEvent: groupName(CRF-) count(4) master(0) event(2), incarn 20, mbrc 4, to member 1, events 0x38, state 0x0
2020-06-16 04:59:02.004: [    CSSD][1]clssgmQueueGrockEvent: groupName(CLSN.ONSPROC.MASTER) count(2) master(1) event(2), incarn 8, mbrc 2, to member 1, events 0xa0, state 0x0
2020-06-16 04:59:02.004: [    CSSD][1]clssgmQueueGrockEvent: groupName(DB+ASM) count(2) master(0) event(2), incarn 8, mbrc 2, to member 0, events 0x68, state 0x0
2020-06-16 04:59:02.004: [    CSSD][1]clssgmQueueGrockEvent: groupName(DG+ASM) count(2) master(0) event(2), incarn 8, mbrc 2, to member 0, events 0x0, state 0x0
2020-06-16 04:59:02.004: [    CSSD][1]clssgmQueueGrockEvent: groupName(IGSNGSNFDBSYS$USERS) count(1) master(1) event(2), incarn 3, mbrc 1, to member 1, events 0x0, state 0x0
2020-06-16 04:59:02.004: [    CSSD][1]clssgmQueueGrockEvent: groupName(IG+ASMSYS$BACKGROUND) count(2) master(1) event(2), incarn 8, mbrc 2, to member 1, events 0x0, state 0x0
2020-06-16 04:59:02.004: [    CSSD][1]clssgmQueueGrockEvent: groupName(VT+ASM) count(2) master(1) event(2), incarn 24, mbrc 2, to member 1, events 0x60, state 0x0
2020-06-16 04:59:02.005: [    CSSD][1]clssgmQueueGrockEvent: groupName(DG+ASM0) count(2) master(0) event(2), incarn 8, mbrc 2, to member 0, events 0x0, state 0x0
2020-06-16 04:59:02.005: [    CSSD][1]clssgmQueueGrockEvent: groupName(GR+GCR1) count(4) master(0) event(2), incarn 56, mbrc 4, to member 0, events 0x280, state 0x0
2020-06-16 04:59:02.005: [    CSSD][1]clssgmQueueGrockEvent: groupName(GR+GCR1) count(4) master(0) event(2), incarn 56, mbrc 4, to member 2, events 0x280, state 0x0
2020-06-16 04:59:02.005: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73587982, LATS 3969073351, lastSeqNo 73546055, uniqueness 1587531535, timestamp 1592254741/2807841238
2020-06-16 04:59:02.005: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254741, 2807841238, 4721103), seedhbimpd TRUE
2020-06-16 04:59:02.005: [    CSSD][19]clssnmvDiskEvict: Kill block write, file /dev/rdsk/c0t6000144000000010A01188CA974BB6E3d0s6 flags 0x00010004, kill block unique 1587531535, stamp 3969073350/3969073350
2020-06-16 04:59:02.005: [    CSSD][1]clssgmQueueGrockEvent: groupName(DG_DATA) count(2) master(0) event(2), incarn 11, mbrc 2, to member 0, events 0x4, state 0x0
2020-06-16 04:59:02.005: [    CSSD][1]clssgmQueueGrockEvent: groupName(IGSNGSNFDBsngsnfdb) count(1) master(1) event(2), incarn 3, mbrc 1, to member 1, events 0x0, state 0x0
2020-06-16 04:59:02.005: [    CSSD][1]clssgmQueueGrockEvent: groupName(CLSFRAME) count(2) master(1) event(2), incarn 8, mbrc 2, to member 1, events 0x8, state 0x0
2020-06-16 04:59:02.005: [    CSSD][1]clssgmQueueGrockEvent: groupName(EVMDMAIN) count(2) master(1) event(2), incarn 8, mbrc 2, to member 1, events 0x8, state 0x0
2020-06-16 04:59:02.005: [    CSSD][1]clssgmQueueGrockEvent: groupName(CRSDMAIN) count(2) master(1) event(2), incarn 8, mbrc 2, to member 1, events 0x8, state 0x0
2020-06-16 04:59:02.005: [    CSSD][1]clssgmQueueGrockEvent: groupName(EVMDMAIN2) count(2) master(1) event(2), incarn 8, mbrc 2, to member 1, events 0x8, state 0x0
2020-06-16 04:59:02.005: [    CSSD][1]clssgmQueueGrockEvent: groupName(CTSSGROUP) count(2) master(1) event(2), incarn 8, mbrc 2, to member 1, events 0x8, state 0x0
2020-06-16 04:59:02.005: [    CSSD][1]clssgmQueueGrockEvent: groupName(DBSNGSNFDB) count(2) master(0) event(2), incarn 2, mbrc 2, to member 0, events 0x68, state 0x0
2020-06-16 04:59:02.005: [    CSSD][1]clssgmQueueGrockEvent: groupName(IGSNGSNFDBSYS$BACKGROUND) count(1) master(1) event(2), incarn 3, mbrc 1, to member 1, events 0x0, state 0x0
2020-06-16 04:59:02.005: [    CSSD][1]clssgmQueueGrockEvent: groupName(DGSNGSNFDB-) count(2) master(0) event(2), incarn 2, mbrc 2, to member 0, events 0x0, state 0x0
2020-06-16 04:59:02.005: [    CSSD][1]clssgmQueueGrockEvent: groupName(DGSNGSNFDB0) count(2) master(0) event(2), incarn 2, mbrc 2, to member 0, events 0x0, state 0x0
2020-06-16 04:59:02.005: [    CSSD][1]clssgmQueueGrockEvent: groupName(IGSNGSNFDBsngsnfdbXDB) count(1) master(1) event(2), incarn 3, mbrc 1, to member 1, events 0x0, state 0x0
2020-06-16 04:59:02.005: [    CSSD][1]clssgmQueueGrockEvent: groupName(ocr_dzswjnfcluster) count(2) master(1) event(2), incarn 8, mbrc 2, to member 1, events 0x78, state 0x0
2020-06-16 04:59:02.005: [    CSSD][1]clssgmQueueGrockEvent: groupName(CLSN.RLB.sngsnfdb.MASTER) count(2) master(1) event(2), incarn 2, mbrc 2, to member 1, events 0xa0, state 0x0
2020-06-16 04:59:02.005: [    CSSD][1]clssgmQueueGrockEvent: groupName(IGSNGSNFDBALL) count(1) master(1) event(2), incarn 3, mbrc 1, to member 1, events 0x0, state 0x0
2020-06-16 04:59:02.005: [    CSSD][1]clssgmSuspendAllGrocks: done
2020-06-16 04:59:02.005: [    CSSD][1]clssgmCompareSwapEventValue: changed CmInfo State  val 2, from 5, changes 82
2020-06-16 04:59:02.005: [    CSSD][1]clssgmUpdateEventValue: ConnectedNodes  val 472333839, changes 25
2020-06-16 04:59:02.005: [    CSSD][1]clssgmCleanupNodeContexts():  cleaning up nodes, rcfg(472333839)
2020-06-16 04:59:02.005: [    CSSD][1]clssgmCleanupNodeContexts():  successful cleanup of nodes rcfg(472333839)
2020-06-16 04:59:02.005: [    CSSD][1]clssgmStartNMMon:  completed node cleanup 
2020-06-16 04:59:02.006: [    CSSD][22]clssgmUpdateEventValue: HoldRequest  val 1, changes 17
2020-06-16 04:59:02.008: [GIPCHAUP][8] gipchaUpperDisconnect: initiated discconnect umsg 104e3fca0 { msg 1079f05d8, ret gipcretRequestPending (15), flags 0x2 }, msg 1079f05d8 { type gipchaMsgTypeDisconnect (5), srcCid 00000000-204c53c4, dstCid 00000000-00000832 }, endp 102d5e750 [00000000204c53c4] { gipchaEndpoint : port 'nm2_dzswjnfcluster/a25f-b3eb-696a-9284', peer 'dzswjnfdb2:a038-b830-1634-21d7', srcCid 00000000-204c53c4,  dstCid 00000000-00000832, numSend 0, maxSend 100, groupListType 2, hagroup 1004fcfe0, usrFlags 0x4000, flags 0x21c }
2020-06-16 04:59:02.008: [    CSSD][22]clssgmRPCDone: rpc 100fff930 (RPC#1940) state 6, flags 0x202
2020-06-16 04:59:02.008: [    CSSD][22]clssgmMbrKillCmpl: Response to invalid member kill request. id 8 Grock DBSNGSNFDB requesting node 1 
2020-06-16 04:59:02.008: [    CSSD][22]clssgmFreeRPCIndex: freeing rpc 1940
2020-06-16 04:59:02.009: [GIPCHAUP][8] gipchaUpperCallbackDisconnect: completed DISCONNECT ret gipcretSuccess (0), umsg 104e3fca0 { msg 1079f05d8, ret gipcretSuccess (0), flags 0x2 }, msg 1079f05d8 { type gipchaMsgTypeDisconnect (5), srcCid 00000000-204c53c4, dstCid 00000000-00000832 }, hendp 102d5e750 [00000000204c53c4] { gipchaEndpoint : port 'nm2_dzswjnfcluster/a25f-b3eb-696a-9284', peer 'dzswjnfdb2:a038-b830-1634-21d7', srcCid 00000000-204c53c4,  dstCid 00000000-00000832, numSend 0, maxSend 100, groupListType 2, hagroup 1004fcfe0, usrFlags 0x4000, flags 0x21c }
2020-06-16 04:59:02.105: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254741, 2807841238, 4721103), seedhbimpd TRUE
2020-06-16 04:59:02.205: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254741, 2807841238, 4721103), seedhbimpd TRUE
2020-06-16 04:59:02.305: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254741, 2807841238, 4721103), seedhbimpd TRUE
2020-06-16 04:59:02.326: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254742/3969073673
2020-06-16 04:59:02.405: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254741, 2807841238, 4721103), seedhbimpd TRUE
2020-06-16 04:59:02.505: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254741, 2807841238, 4721103), seedhbimpd TRUE
2020-06-16 04:59:02.506: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73587983, LATS 3969073853, lastSeqNo 73587982, uniqueness 1587531535, timestamp 1592254742/2807842239
2020-06-16 04:59:02.506: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254742, 2807842239, 4721104), seedhbimpd TRUE
2020-06-16 04:59:02.607: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254742, 2807842239, 4721104), seedhbimpd TRUE
2020-06-16 04:59:02.676: [    CSSD][18]clssnmvDiskKillCheck: not evicted, file /dev/rdsk/c0t6000144000000010A01188CA974BB6E3d0s6 flags 0x00000000, kill block unique 0, my unique 1576839012
2020-06-16 04:59:02.707: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254742, 2807842239, 4721104), seedhbimpd TRUE
2020-06-16 04:59:02.807: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254742, 2807842239, 4721104), seedhbimpd TRUE
2020-06-16 04:59:02.828: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254742/3969074174
2020-06-16 04:59:02.907: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254742, 2807842239, 4721104), seedhbimpd TRUE
2020-06-16 04:59:03.004: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254742, 2807842239, 4721104), seedhbimpd TRUE
2020-06-16 04:59:03.008: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254742, 2807842239, 4721104), seedhbimpd TRUE
2020-06-16 04:59:03.108: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254742, 2807842239, 4721104), seedhbimpd TRUE
2020-06-16 04:59:03.208: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254742, 2807842239, 4721104), seedhbimpd TRUE
2020-06-16 04:59:03.308: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254742, 2807842239, 4721104), seedhbimpd TRUE
2020-06-16 04:59:03.328: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254743/3969074675
2020-06-16 04:59:03.363: [    CSSD][24]clssnmSendingThread: sending status msg to all nodes
2020-06-16 04:59:03.363: [    CSSD][24]clssnmSendingThread: sent 4 status msgs to all nodes
2020-06-16 04:59:03.408: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254742, 2807842239, 4721104), seedhbimpd TRUE
2020-06-16 04:59:03.508: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254742, 2807842239, 4721104), seedhbimpd TRUE
2020-06-16 04:59:03.509: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73587984, LATS 3969074855, lastSeqNo 73587983, uniqueness 1587531535, timestamp 1592254743/2807843241
2020-06-16 04:59:03.509: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254743, 2807843241, 4721105), seedhbimpd TRUE
2020-06-16 04:59:03.609: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254743, 2807843241, 4721105), seedhbimpd TRUE
2020-06-16 04:59:03.677: [    CSSD][18]clssnmvDiskKillCheck: not evicted, file /dev/rdsk/c0t6000144000000010A01188CA974BB6E3d0s6 flags 0x00000000, kill block unique 0, my unique 1576839012
2020-06-16 04:59:03.709: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254743, 2807843241, 4721105), seedhbimpd TRUE
2020-06-16 04:59:03.809: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254743, 2807843241, 4721105), seedhbimpd TRUE
2020-06-16 04:59:03.830: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254743/3969075176
2020-06-16 04:59:03.909: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254743, 2807843241, 4721105), seedhbimpd TRUE
2020-06-16 04:59:04.004: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254743, 2807843241, 4721105), seedhbimpd TRUE
2020-06-16 04:59:04.011: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73587985, LATS 3969075357, lastSeqNo 73587984, uniqueness 1587531535, timestamp 1592254743/2807843742
2020-06-16 04:59:04.011: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254743, 2807843742, 4721105), seedhbimpd TRUE
2020-06-16 04:59:04.111: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254743, 2807843742, 4721105), seedhbimpd TRUE
2020-06-16 04:59:04.211: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254743, 2807843742, 4721105), seedhbimpd TRUE
2020-06-16 04:59:04.311: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254743, 2807843742, 4721105), seedhbimpd TRUE
2020-06-16 04:59:04.330: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254744/3969075677
2020-06-16 04:59:04.411: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254743, 2807843742, 4721105), seedhbimpd TRUE
2020-06-16 04:59:04.511: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254743, 2807843742, 4721105), seedhbimpd TRUE
2020-06-16 04:59:04.512: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73587986, LATS 3969075858, lastSeqNo 73587985, uniqueness 1587531535, timestamp 1592254744/2807844244
2020-06-16 04:59:04.512: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254744, 2807844244, 4721106), seedhbimpd TRUE
2020-06-16 04:59:04.612: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254744, 2807844244, 4721106), seedhbimpd TRUE
2020-06-16 04:59:04.677: [    CSSD][18]clssnmvDiskKillCheck: not evicted, file /dev/rdsk/c0t6000144000000010A01188CA974BB6E3d0s6 flags 0x00000000, kill block unique 0, my unique 1576839012
2020-06-16 04:59:04.712: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254744, 2807844244, 4721106), seedhbimpd TRUE
2020-06-16 04:59:04.812: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254744, 2807844244, 4721106), seedhbimpd TRUE
2020-06-16 04:59:04.832: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254744/3969076178
2020-06-16 04:59:04.912: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254744, 2807844244, 4721106), seedhbimpd TRUE
2020-06-16 04:59:05.004: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254744, 2807844244, 4721106), seedhbimpd TRUE
2020-06-16 04:59:05.013: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73587987, LATS 3969076359, lastSeqNo 73587986, uniqueness 1587531535, timestamp 1592254744/2807844745
2020-06-16 04:59:05.013: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254744, 2807844745, 4721106), seedhbimpd TRUE
2020-06-16 04:59:05.113: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254744, 2807844745, 4721106), seedhbimpd TRUE
2020-06-16 04:59:05.213: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254744, 2807844745, 4721106), seedhbimpd TRUE
2020-06-16 04:59:05.313: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254744, 2807844745, 4721106), seedhbimpd TRUE
2020-06-16 04:59:05.333: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254745/3969076679
2020-06-16 04:59:05.414: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254744, 2807844745, 4721106), seedhbimpd TRUE
2020-06-16 04:59:05.514: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254744, 2807844745, 4721106), seedhbimpd TRUE
2020-06-16 04:59:05.515: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73587988, LATS 3969076861, lastSeqNo 73587987, uniqueness 1587531535, timestamp 1592254745/2807845246
2020-06-16 04:59:05.515: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254745, 2807845246, 4721107), seedhbimpd TRUE
2020-06-16 04:59:05.615: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254745, 2807845246, 4721107), seedhbimpd TRUE
2020-06-16 04:59:05.678: [    CSSD][18]clssnmvDiskKillCheck: not evicted, file /dev/rdsk/c0t6000144000000010A01188CA974BB6E3d0s6 flags 0x00000000, kill block unique 0, my unique 1576839012
2020-06-16 04:59:05.715: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254745, 2807845246, 4721107), seedhbimpd TRUE
2020-06-16 04:59:05.815: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254745, 2807845246, 4721107), seedhbimpd TRUE
2020-06-16 04:59:05.833: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254745/3969077180
2020-06-16 04:59:05.915: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254745, 2807845246, 4721107), seedhbimpd TRUE
2020-06-16 04:59:06.004: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254745, 2807845246, 4721107), seedhbimpd TRUE
2020-06-16 04:59:06.016: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73587989, LATS 3969077362, lastSeqNo 73587988, uniqueness 1587531535, timestamp 1592254745/2807845747
2020-06-16 04:59:06.016: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254745, 2807845747, 4721107), seedhbimpd TRUE
2020-06-16 04:59:06.116: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254745, 2807845747, 4721107), seedhbimpd TRUE
2020-06-16 04:59:06.216: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254745, 2807845747, 4721107), seedhbimpd TRUE
2020-06-16 04:59:06.316: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254745, 2807845747, 4721107), seedhbimpd TRUE
2020-06-16 04:59:06.334: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254746/3969077681
2020-06-16 04:59:06.416: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254745, 2807845747, 4721107), seedhbimpd TRUE
2020-06-16 04:59:06.516: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254745, 2807845747, 4721107), seedhbimpd TRUE
2020-06-16 04:59:06.518: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73587990, LATS 3969077864, lastSeqNo 73587989, uniqueness 1587531535, timestamp 1592254746/2807846248
2020-06-16 04:59:06.518: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254746, 2807846248, 4721108), seedhbimpd TRUE
2020-06-16 04:59:06.618: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254746, 2807846248, 4721108), seedhbimpd TRUE
2020-06-16 04:59:06.678: [    CSSD][18]clssnmvDiskKillCheck: not evicted, file /dev/rdsk/c0t6000144000000010A01188CA974BB6E3d0s6 flags 0x00000000, kill block unique 0, my unique 1576839012
2020-06-16 04:59:06.718: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254746, 2807846248, 4721108), seedhbimpd TRUE
2020-06-16 04:59:06.818: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254746, 2807846248, 4721108), seedhbimpd TRUE
2020-06-16 04:59:06.835: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254746/3969078181
2020-06-16 04:59:06.918: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254746, 2807846248, 4721108), seedhbimpd TRUE
2020-06-16 04:59:07.004: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254746, 2807846248, 4721108), seedhbimpd TRUE
2020-06-16 04:59:07.020: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73587991, LATS 3969078366, lastSeqNo 73587990, uniqueness 1587531535, timestamp 1592254746/2807846749
2020-06-16 04:59:07.020: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254746, 2807846749, 4721108), seedhbimpd TRUE
2020-06-16 04:59:07.120: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254746, 2807846749, 4721108), seedhbimpd TRUE
2020-06-16 04:59:07.220: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254746, 2807846749, 4721108), seedhbimpd TRUE
2020-06-16 04:59:07.320: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254746, 2807846749, 4721108), seedhbimpd TRUE
2020-06-16 04:59:07.337: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254747/3969078683
2020-06-16 04:59:07.365: [    CSSD][24]clssnmSendingThread: sending status msg to all nodes
2020-06-16 04:59:07.365: [    CSSD][24]clssnmSendingThread: sent 8 status msgs to all nodes
2020-06-16 04:59:07.420: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254746, 2807846749, 4721108), seedhbimpd TRUE
2020-06-16 04:59:07.520: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254746, 2807846749, 4721108), seedhbimpd TRUE
2020-06-16 04:59:07.521: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73587992, LATS 3969078867, lastSeqNo 73587991, uniqueness 1587531535, timestamp 1592254747/2807847250
2020-06-16 04:59:07.521: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254747, 2807847250, 4721109), seedhbimpd TRUE
2020-06-16 04:59:07.621: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254747, 2807847250, 4721109), seedhbimpd TRUE
2020-06-16 04:59:07.679: [    CSSD][18]clssnmvDiskKillCheck: not evicted, file /dev/rdsk/c0t6000144000000010A01188CA974BB6E3d0s6 flags 0x00000000, kill block unique 0, my unique 1576839012
2020-06-16 04:59:07.721: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254747, 2807847250, 4721109), seedhbimpd TRUE
2020-06-16 04:59:07.821: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254747, 2807847250, 4721109), seedhbimpd TRUE
2020-06-16 04:59:07.837: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254747/3969079184
2020-06-16 04:59:07.921: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254747, 2807847250, 4721109), seedhbimpd TRUE
2020-06-16 04:59:08.004: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254747, 2807847250, 4721109), seedhbimpd TRUE
2020-06-16 04:59:08.022: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73587993, LATS 3969079368, lastSeqNo 73587992, uniqueness 1587531535, timestamp 1592254747/2807847752
2020-06-16 04:59:08.022: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254747, 2807847752, 4721109), seedhbimpd TRUE
2020-06-16 04:59:08.122: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254747, 2807847752, 4721109), seedhbimpd TRUE
2020-06-16 04:59:08.222: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254747, 2807847752, 4721109), seedhbimpd TRUE
2020-06-16 04:59:08.322: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254747, 2807847752, 4721109), seedhbimpd TRUE
2020-06-16 04:59:08.339: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254748/3969079685
2020-06-16 04:59:08.423: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254747, 2807847752, 4721109), seedhbimpd TRUE
2020-06-16 04:59:08.523: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254747, 2807847752, 4721109), seedhbimpd TRUE
2020-06-16 04:59:08.524: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73587994, LATS 3969079870, lastSeqNo 73587993, uniqueness 1587531535, timestamp 1592254748/2807848253
2020-06-16 04:59:08.524: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254748, 2807848253, 4721110), seedhbimpd TRUE
2020-06-16 04:59:08.624: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254748, 2807848253, 4721110), seedhbimpd TRUE
2020-06-16 04:59:08.679: [    CSSD][18]clssnmvDiskKillCheck: not evicted, file /dev/rdsk/c0t6000144000000010A01188CA974BB6E3d0s6 flags 0x00000000, kill block unique 0, my unique 1576839012
2020-06-16 04:59:08.724: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254748, 2807848253, 4721110), seedhbimpd TRUE
2020-06-16 04:59:08.824: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254748, 2807848253, 4721110), seedhbimpd TRUE
2020-06-16 04:59:08.840: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254748/3969080187
2020-06-16 04:59:08.924: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254748, 2807848253, 4721110), seedhbimpd TRUE
2020-06-16 04:59:09.004: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254748, 2807848253, 4721110), seedhbimpd TRUE
2020-06-16 04:59:09.025: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73587995, LATS 3969080371, lastSeqNo 73587994, uniqueness 1587531535, timestamp 1592254748/2807848755
2020-06-16 04:59:09.025: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254748, 2807848755, 4721110), seedhbimpd TRUE
2020-06-16 04:59:09.125: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254748, 2807848755, 4721110), seedhbimpd TRUE
2020-06-16 04:59:09.225: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254748, 2807848755, 4721110), seedhbimpd TRUE
2020-06-16 04:59:09.325: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254748, 2807848755, 4721110), seedhbimpd TRUE
2020-06-16 04:59:09.341: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254749/3969080688
2020-06-16 04:59:09.425: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254748, 2807848755, 4721110), seedhbimpd TRUE
2020-06-16 04:59:09.525: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254748, 2807848755, 4721110), seedhbimpd TRUE
2020-06-16 04:59:09.526: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73587996, LATS 3969080872, lastSeqNo 73587995, uniqueness 1587531535, timestamp 1592254749/2807849256
2020-06-16 04:59:09.526: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254749, 2807849256, 4721111), seedhbimpd TRUE
2020-06-16 04:59:09.626: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254749, 2807849256, 4721111), seedhbimpd TRUE
2020-06-16 04:59:09.679: [    CSSD][18]clssnmvDiskKillCheck: not evicted, file /dev/rdsk/c0t6000144000000010A01188CA974BB6E3d0s6 flags 0x00000000, kill block unique 0, my unique 1576839012
2020-06-16 04:59:09.726: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254749, 2807849256, 4721111), seedhbimpd TRUE
2020-06-16 04:59:09.826: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254749, 2807849256, 4721111), seedhbimpd TRUE
2020-06-16 04:59:09.842: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254749/3969081188
2020-06-16 04:59:09.926: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254749, 2807849256, 4721111), seedhbimpd TRUE
2020-06-16 04:59:10.004: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254749, 2807849256, 4721111), seedhbimpd TRUE
2020-06-16 04:59:10.027: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73587997, LATS 3969081373, lastSeqNo 73587996, uniqueness 1587531535, timestamp 1592254749/2807849759
2020-06-16 04:59:10.027: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254749, 2807849759, 4721111), seedhbimpd TRUE
2020-06-16 04:59:10.127: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254749, 2807849759, 4721111), seedhbimpd TRUE
2020-06-16 04:59:10.227: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254749, 2807849759, 4721111), seedhbimpd TRUE
2020-06-16 04:59:10.327: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254749, 2807849759, 4721111), seedhbimpd TRUE
2020-06-16 04:59:10.343: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254750/3969081689
2020-06-16 04:59:10.427: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254749, 2807849759, 4721111), seedhbimpd TRUE
2020-06-16 04:59:10.528: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254749, 2807849759, 4721111), seedhbimpd TRUE
2020-06-16 04:59:10.529: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73587998, LATS 3969081875, lastSeqNo 73587997, uniqueness 1587531535, timestamp 1592254750/2807850260
2020-06-16 04:59:10.529: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254750, 2807850260, 4721112), seedhbimpd TRUE
2020-06-16 04:59:10.629: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254750, 2807850260, 4721112), seedhbimpd TRUE
2020-06-16 04:59:10.680: [    CSSD][18]clssnmvDiskKillCheck: not evicted, file /dev/rdsk/c0t6000144000000010A01188CA974BB6E3d0s6 flags 0x00000000, kill block unique 0, my unique 1576839012
2020-06-16 04:59:10.729: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254750, 2807850260, 4721112), seedhbimpd TRUE
2020-06-16 04:59:10.829: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254750, 2807850260, 4721112), seedhbimpd TRUE
2020-06-16 04:59:10.844: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254750/3969082190
2020-06-16 04:59:10.929: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254750, 2807850260, 4721112), seedhbimpd TRUE
2020-06-16 04:59:11.004: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254750, 2807850260, 4721112), seedhbimpd TRUE
2020-06-16 04:59:11.030: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73587999, LATS 3969082376, lastSeqNo 73587998, uniqueness 1587531535, timestamp 1592254750/2807850761
2020-06-16 04:59:11.030: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254750, 2807850761, 4721112), seedhbimpd TRUE
2020-06-16 04:59:11.130: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254750, 2807850761, 4721112), seedhbimpd TRUE
2020-06-16 04:59:11.230: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254750, 2807850761, 4721112), seedhbimpd TRUE
2020-06-16 04:59:11.330: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254750, 2807850761, 4721112), seedhbimpd TRUE
2020-06-16 04:59:11.346: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254751/3969082692
2020-06-16 04:59:11.367: [    CSSD][24]clssnmSendingThread: sending status msg to all nodes
2020-06-16 04:59:11.367: [    CSSD][24]clssnmSendingThread: sent 8 status msgs to all nodes
2020-06-16 04:59:11.431: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254750, 2807850761, 4721112), seedhbimpd TRUE
2020-06-16 04:59:11.531: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254750, 2807850761, 4721112), seedhbimpd TRUE
2020-06-16 04:59:11.532: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73588000, LATS 3969082878, lastSeqNo 73587999, uniqueness 1587531535, timestamp 1592254751/2807851263
2020-06-16 04:59:11.532: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254751, 2807851263, 4721113), seedhbimpd TRUE
2020-06-16 04:59:11.632: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254751, 2807851263, 4721113), seedhbimpd TRUE
2020-06-16 04:59:11.680: [    CSSD][18]clssnmvDiskKillCheck: not evicted, file /dev/rdsk/c0t6000144000000010A01188CA974BB6E3d0s6 flags 0x00000000, kill block unique 0, my unique 1576839012
2020-06-16 04:59:11.732: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254751, 2807851263, 4721113), seedhbimpd TRUE
2020-06-16 04:59:11.832: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254751, 2807851263, 4721113), seedhbimpd TRUE
2020-06-16 04:59:11.846: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254751/3969083192
2020-06-16 04:59:11.932: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254751, 2807851263, 4721113), seedhbimpd TRUE
2020-06-16 04:59:12.004: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254751, 2807851263, 4721113), seedhbimpd TRUE
2020-06-16 04:59:12.033: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73588001, LATS 3969083379, lastSeqNo 73588000, uniqueness 1587531535, timestamp 1592254751/2807851764
2020-06-16 04:59:12.033: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254751, 2807851764, 4721113), seedhbimpd TRUE
2020-06-16 04:59:12.033: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:12.033: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:12.133: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254751, 2807851764, 4721113), seedhbimpd TRUE
2020-06-16 04:59:12.133: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:12.133: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:12.233: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254751, 2807851764, 4721113), seedhbimpd TRUE
2020-06-16 04:59:12.233: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:12.233: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:12.334: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254751, 2807851764, 4721113), seedhbimpd TRUE
2020-06-16 04:59:12.334: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:12.334: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:12.348: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254752/3969083694
2020-06-16 04:59:12.434: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254751, 2807851764, 4721113), seedhbimpd TRUE
2020-06-16 04:59:12.434: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:12.434: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:12.534: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254751, 2807851764, 4721113), seedhbimpd TRUE
2020-06-16 04:59:12.534: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:12.534: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:12.535: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73588002, LATS 3969083881, lastSeqNo 73588001, uniqueness 1587531535, timestamp 1592254752/2807852265
2020-06-16 04:59:12.535: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254752, 2807852265, 4721114), seedhbimpd TRUE
2020-06-16 04:59:12.535: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:12.535: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:12.635: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254752, 2807852265, 4721114), seedhbimpd TRUE
2020-06-16 04:59:12.635: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:12.635: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:12.680: [    CSSD][18]clssnmvDiskKillCheck: not evicted, file /dev/rdsk/c0t6000144000000010A01188CA974BB6E3d0s6 flags 0x00000000, kill block unique 0, my unique 1576839012
2020-06-16 04:59:12.735: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254752, 2807852265, 4721114), seedhbimpd TRUE
2020-06-16 04:59:12.735: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:12.735: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:12.835: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254752, 2807852265, 4721114), seedhbimpd TRUE
2020-06-16 04:59:12.835: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:12.835: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:12.849: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254752/3969084195
2020-06-16 04:59:12.935: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254752, 2807852265, 4721114), seedhbimpd TRUE
2020-06-16 04:59:12.935: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:12.935: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:13.004: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254752, 2807852265, 4721114), seedhbimpd TRUE
2020-06-16 04:59:13.004: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:13.004: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:13.036: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73588003, LATS 3969084382, lastSeqNo 73588002, uniqueness 1587531535, timestamp 1592254752/2807852766
2020-06-16 04:59:13.036: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254752, 2807852766, 4721114), seedhbimpd TRUE
2020-06-16 04:59:13.036: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:13.036: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:13.136: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254752, 2807852766, 4721114), seedhbimpd TRUE
2020-06-16 04:59:13.136: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:13.136: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:13.236: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254752, 2807852766, 4721114), seedhbimpd TRUE
2020-06-16 04:59:13.236: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:13.236: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:13.336: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254752, 2807852766, 4721114), seedhbimpd TRUE
2020-06-16 04:59:13.337: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:13.337: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:13.350: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254753/3969084696
2020-06-16 04:59:13.437: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254752, 2807852766, 4721114), seedhbimpd TRUE
2020-06-16 04:59:13.437: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:13.437: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:13.537: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254752, 2807852766, 4721114), seedhbimpd TRUE
2020-06-16 04:59:13.537: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:13.537: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:13.537: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73588004, LATS 3969084883, lastSeqNo 73588003, uniqueness 1587531535, timestamp 1592254753/2807853267
2020-06-16 04:59:13.537: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254753, 2807853267, 4721115), seedhbimpd TRUE
2020-06-16 04:59:13.537: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:13.537: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:13.637: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254753, 2807853267, 4721115), seedhbimpd TRUE
2020-06-16 04:59:13.637: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:13.637: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:13.680: [    CSSD][18]clssnmvDiskKillCheck: not evicted, file /dev/rdsk/c0t6000144000000010A01188CA974BB6E3d0s6 flags 0x00000000, kill block unique 0, my unique 1576839012
2020-06-16 04:59:13.737: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254753, 2807853267, 4721115), seedhbimpd TRUE
2020-06-16 04:59:13.737: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:13.737: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:13.837: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254753, 2807853267, 4721115), seedhbimpd TRUE
2020-06-16 04:59:13.838: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:13.838: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:13.851: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254753/3969085197
2020-06-16 04:59:13.938: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254753, 2807853267, 4721115), seedhbimpd TRUE
2020-06-16 04:59:13.938: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:13.938: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:14.004: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254753, 2807853267, 4721115), seedhbimpd TRUE
2020-06-16 04:59:14.004: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:14.004: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:14.039: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73588005, LATS 3969085385, lastSeqNo 73588004, uniqueness 1587531535, timestamp 1592254753/2807853768
2020-06-16 04:59:14.039: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254753, 2807853768, 4721115), seedhbimpd TRUE
2020-06-16 04:59:14.039: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:14.039: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:14.139: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254753, 2807853768, 4721115), seedhbimpd TRUE
2020-06-16 04:59:14.139: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:14.139: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:14.239: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254753, 2807853768, 4721115), seedhbimpd TRUE
2020-06-16 04:59:14.239: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:14.239: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:14.339: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254753, 2807853768, 4721115), seedhbimpd TRUE
2020-06-16 04:59:14.339: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:14.339: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:14.352: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254754/3969085698
2020-06-16 04:59:14.439: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254753, 2807853768, 4721115), seedhbimpd TRUE
2020-06-16 04:59:14.439: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:14.439: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:14.539: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254753, 2807853768, 4721115), seedhbimpd TRUE
2020-06-16 04:59:14.539: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:14.539: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:14.540: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73588006, LATS 3969085886, lastSeqNo 73588005, uniqueness 1587531535, timestamp 1592254754/2807854269
2020-06-16 04:59:14.540: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254754, 2807854269, 4721116), seedhbimpd TRUE
2020-06-16 04:59:14.540: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:14.540: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:14.640: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254754, 2807854269, 4721116), seedhbimpd TRUE
2020-06-16 04:59:14.640: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:14.640: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:14.681: [    CSSD][18]clssnmvDiskKillCheck: not evicted, file /dev/rdsk/c0t6000144000000010A01188CA974BB6E3d0s6 flags 0x00000000, kill block unique 0, my unique 1576839012
2020-06-16 04:59:14.740: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254754, 2807854269, 4721116), seedhbimpd TRUE
2020-06-16 04:59:14.741: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:14.741: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:14.841: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254754, 2807854269, 4721116), seedhbimpd TRUE
2020-06-16 04:59:14.841: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:14.841: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:14.854: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254754/3969086200
2020-06-16 04:59:14.941: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254754, 2807854269, 4721116), seedhbimpd TRUE
2020-06-16 04:59:14.941: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:14.941: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:15.004: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254754, 2807854269, 4721116), seedhbimpd TRUE
2020-06-16 04:59:15.004: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:15.004: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:15.042: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73588007, LATS 3969086388, lastSeqNo 73588006, uniqueness 1587531535, timestamp 1592254754/2807854771
2020-06-16 04:59:15.042: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254754, 2807854771, 4721116), seedhbimpd TRUE
2020-06-16 04:59:15.042: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:15.042: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:15.142: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254754, 2807854771, 4721116), seedhbimpd TRUE
2020-06-16 04:59:15.142: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:15.142: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:15.242: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254754, 2807854771, 4721116), seedhbimpd TRUE
2020-06-16 04:59:15.242: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:15.242: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:15.342: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254754, 2807854771, 4721116), seedhbimpd TRUE
2020-06-16 04:59:15.342: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:15.342: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:15.356: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254755/3969086702
2020-06-16 04:59:15.369: [    CSSD][24]clssnmSendingThread: sending status msg to all nodes
2020-06-16 04:59:15.369: [    CSSD][24]clssnmSendingThread: sent 8 status msgs to all nodes
2020-06-16 04:59:15.442: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254754, 2807854771, 4721116), seedhbimpd TRUE
2020-06-16 04:59:15.442: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:15.442: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:15.543: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254754, 2807854771, 4721116), seedhbimpd TRUE
2020-06-16 04:59:15.543: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:15.543: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:15.543: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73588008, LATS 3969086889, lastSeqNo 73588007, uniqueness 1587531535, timestamp 1592254755/2807855272
2020-06-16 04:59:15.543: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254755, 2807855272, 4721117), seedhbimpd TRUE
2020-06-16 04:59:15.543: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:15.543: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:15.643: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254755, 2807855272, 4721117), seedhbimpd TRUE
2020-06-16 04:59:15.643: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:15.643: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:15.681: [    CSSD][18]clssnmvDiskKillCheck: not evicted, file /dev/rdsk/c0t6000144000000010A01188CA974BB6E3d0s6 flags 0x00000000, kill block unique 0, my unique 1576839012
2020-06-16 04:59:15.743: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254755, 2807855272, 4721117), seedhbimpd TRUE
2020-06-16 04:59:15.743: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:15.743: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:15.843: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254755, 2807855272, 4721117), seedhbimpd TRUE
2020-06-16 04:59:15.843: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:15.843: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:15.857: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254755/3969087203
2020-06-16 04:59:15.943: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254755, 2807855272, 4721117), seedhbimpd TRUE
2020-06-16 04:59:15.943: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:15.943: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:16.004: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254755, 2807855272, 4721117), seedhbimpd TRUE
2020-06-16 04:59:16.005: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:16.005: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:16.044: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73588009, LATS 3969087390, lastSeqNo 73588008, uniqueness 1587531535, timestamp 1592254755/2807855774
2020-06-16 04:59:16.044: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254755, 2807855774, 4721117), seedhbimpd TRUE
2020-06-16 04:59:16.044: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:16.044: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:16.144: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254755, 2807855774, 4721117), seedhbimpd TRUE
2020-06-16 04:59:16.144: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:16.144: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:16.244: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254755, 2807855774, 4721117), seedhbimpd TRUE
2020-06-16 04:59:16.245: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:16.245: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:16.345: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254755, 2807855774, 4721117), seedhbimpd TRUE
2020-06-16 04:59:16.345: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:16.345: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:16.358: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254756/3969087704
2020-06-16 04:59:16.445: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254755, 2807855774, 4721117), seedhbimpd TRUE
2020-06-16 04:59:16.445: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:16.445: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:16.545: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254755, 2807855774, 4721117), seedhbimpd TRUE
2020-06-16 04:59:16.545: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:16.545: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:16.546: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73588010, LATS 3969087892, lastSeqNo 73588009, uniqueness 1587531535, timestamp 1592254756/2807856275
2020-06-16 04:59:16.546: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254756, 2807856275, 4721118), seedhbimpd TRUE
2020-06-16 04:59:16.546: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:16.546: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:16.646: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254756, 2807856275, 4721118), seedhbimpd TRUE
2020-06-16 04:59:16.646: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:16.646: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:16.681: [    CSSD][18]clssnmvDiskKillCheck: not evicted, file /dev/rdsk/c0t6000144000000010A01188CA974BB6E3d0s6 flags 0x00000000, kill block unique 0, my unique 1576839012
2020-06-16 04:59:16.746: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254756, 2807856275, 4721118), seedhbimpd TRUE
2020-06-16 04:59:16.746: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:16.746: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:16.846: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254756, 2807856275, 4721118), seedhbimpd TRUE
2020-06-16 04:59:16.846: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:16.846: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:16.859: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254756/3969088205
2020-06-16 04:59:16.946: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254756, 2807856275, 4721118), seedhbimpd TRUE
2020-06-16 04:59:16.946: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:16.946: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:17.005: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254756, 2807856275, 4721118), seedhbimpd TRUE
2020-06-16 04:59:17.005: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:17.005: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:17.047: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73588011, LATS 3969088393, lastSeqNo 73588010, uniqueness 1587531535, timestamp 1592254756/2807856777
2020-06-16 04:59:17.047: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254756, 2807856777, 4721118), seedhbimpd TRUE
2020-06-16 04:59:17.047: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:17.047: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:17.147: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254756, 2807856777, 4721118), seedhbimpd TRUE
2020-06-16 04:59:17.147: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:17.147: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:17.247: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254756, 2807856777, 4721118), seedhbimpd TRUE
2020-06-16 04:59:17.247: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:17.247: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:17.347: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254756, 2807856777, 4721118), seedhbimpd TRUE
2020-06-16 04:59:17.347: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:17.347: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:17.360: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254757/3969088706
2020-06-16 04:59:17.447: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254756, 2807856777, 4721118), seedhbimpd TRUE
2020-06-16 04:59:17.447: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:17.447: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:17.547: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254756, 2807856777, 4721118), seedhbimpd TRUE
2020-06-16 04:59:17.547: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:17.547: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:17.548: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73588012, LATS 3969088894, lastSeqNo 73588011, uniqueness 1587531535, timestamp 1592254757/2807857278
2020-06-16 04:59:17.548: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254757, 2807857278, 4721119), seedhbimpd TRUE
2020-06-16 04:59:17.548: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:17.548: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:17.648: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254757, 2807857278, 4721119), seedhbimpd TRUE
2020-06-16 04:59:17.648: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:17.648: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:17.682: [    CSSD][18]clssnmvDiskKillCheck: not evicted, file /dev/rdsk/c0t6000144000000010A01188CA974BB6E3d0s6 flags 0x00000000, kill block unique 0, my unique 1576839012
2020-06-16 04:59:17.748: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254757, 2807857278, 4721119), seedhbimpd TRUE
2020-06-16 04:59:17.748: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:17.748: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:17.848: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254757, 2807857278, 4721119), seedhbimpd TRUE
2020-06-16 04:59:17.848: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:17.848: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:17.861: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254757/3969089207
2020-06-16 04:59:17.948: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254757, 2807857278, 4721119), seedhbimpd TRUE
2020-06-16 04:59:17.948: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:17.948: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:18.005: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254757, 2807857278, 4721119), seedhbimpd TRUE
2020-06-16 04:59:18.005: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:18.005: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:18.049: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73588013, LATS 3969089395, lastSeqNo 73588012, uniqueness 1587531535, timestamp 1592254757/2807857780
2020-06-16 04:59:18.049: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254757, 2807857780, 4721119), seedhbimpd TRUE
2020-06-16 04:59:18.049: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:18.049: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:18.149: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254757, 2807857780, 4721119), seedhbimpd TRUE
2020-06-16 04:59:18.149: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:18.149: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:18.249: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254757, 2807857780, 4721119), seedhbimpd TRUE
2020-06-16 04:59:18.249: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:18.249: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:18.349: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254757, 2807857780, 4721119), seedhbimpd TRUE
2020-06-16 04:59:18.349: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:18.349: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:18.362: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254758/3969089708
2020-06-16 04:59:18.449: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254757, 2807857780, 4721119), seedhbimpd TRUE
2020-06-16 04:59:18.449: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:18.449: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:18.549: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254757, 2807857780, 4721119), seedhbimpd TRUE
2020-06-16 04:59:18.549: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:18.549: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:18.550: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73588014, LATS 3969089896, lastSeqNo 73588013, uniqueness 1587531535, timestamp 1592254758/2807858281
2020-06-16 04:59:18.550: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254758, 2807858281, 4721120), seedhbimpd TRUE
2020-06-16 04:59:18.550: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:18.550: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:18.650: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254758, 2807858281, 4721120), seedhbimpd TRUE
2020-06-16 04:59:18.650: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:18.650: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:18.682: [    CSSD][18]clssnmvDiskKillCheck: not evicted, file /dev/rdsk/c0t6000144000000010A01188CA974BB6E3d0s6 flags 0x00000000, kill block unique 0, my unique 1576839012
2020-06-16 04:59:18.750: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254758, 2807858281, 4721120), seedhbimpd TRUE
2020-06-16 04:59:18.750: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:18.750: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:18.850: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254758, 2807858281, 4721120), seedhbimpd TRUE
2020-06-16 04:59:18.850: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:18.850: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:18.863: [    CSSD][17]clssnmvDiskPing: Writing with status 0x3, timestamp 1592254758/3969090209
2020-06-16 04:59:18.950: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254758, 2807858281, 4721120), seedhbimpd TRUE
2020-06-16 04:59:18.950: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:18.950: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:19.005: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254758, 2807858281, 4721120), seedhbimpd TRUE
2020-06-16 04:59:19.005: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:19.005: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:19.051: [    CSSD][19]clssnmvDHBValidateNcopy: node 2, dzswjnfdb2, has a disk HB, but no network HB, DHB has rcfg 472333840, wrtcnt, 73588015, LATS 3969090397, lastSeqNo 73588014, uniqueness 1587531535, timestamp 1592254758/2807858783
2020-06-16 04:59:19.051: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254758, 2807858783, 4721120), seedhbimpd TRUE
2020-06-16 04:59:19.051: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured
2020-06-16 04:59:19.051: [    CSSD][25]clssnmWaitOnEviction: Node kill could not beperformed. Admin or connection validation failed
2020-06-16 04:59:19.151: [    CSSD][25]clssnmWaitOnEvictions: node 2, undead 1, EXADATA fence handle 0 kill reqest id 0, last DHB (1592254758, 2807858783, 4721120), seedhbimpd TRUE
2020-06-16 04:59:19.151: [    CSSD][25]clssnmWaitOnEviction: node(2) exceeded graceful shutdown period, IPMI-kill allowed if configured


##节点1 crs日志
2020-06-16 04:58:31.502: 
[cssd(1602)]CRS-1663:Member kill issued by PID 23954 for 1 members, group DBSNGSNFDB. Details at (:CSSGM00044:) in /u01/app/11.2.0.4/grid/log/dzswjnfdb1/cssd/ocssd.log.
2020-06-16 04:59:02.004: 
[cssd(1602)]CRS-1607:Node dzswjnfdb2 is being evicted in cluster incarnation 472333840; details at (:CSSNM00007:) in /u01/app/11.2.0.4/grid/log/dzswjnfdb1/cssd/ocssd.log.
2020-06-16 09:24:51.429: 
[cssd(1602)]CRS-1601:CSSD Reconfiguration complete. Active nodes are dzswjnfdb1 .
2020-06-16 09:24:51.434: 
[crsd(2356)]CRS-5504:Node down event reported for node 'dzswjnfdb2'.
2020-06-16 09:24:56.696: 
[crsd(2356)]CRS-2773:Server 'dzswjnfdb2' has been removed from pool 'ora.sngsnfdb'.
2020-06-16 09:24:56.696: 
[crsd(2356)]CRS-2773:Server 'dzswjnfdb2' has been removed from pool 'Generic'.
2020-06-16 09:26:40.628: 
[cssd(1602)]CRS-1601:CSSD Reconfiguration complete. Active nodes are dzswjnfdb1 dzswjnfdb2 .
2020-06-16 09:27:33.243: 
[crsd(2356)]CRS-2772:Server 'dzswjnfdb2' has been assigned to pool 'Generic'.
2020-06-16 09:27:33.244: 
[crsd(2356)]CRS-2772:Server 'dzswjnfdb2' has been assigned to pool 'ora.sngsnfdb'.
2020-06-16 09:28:24.040: 
[crsd(2356)]CRS-2807:Resource 'ora.sngsnfdb.db' failed to start automatically.


##ASM日志
Tue Jun 16 09:24:51 2020
Reconfiguration started (old inc 16, new inc 18)
List of instances:
 1 (myinst: 1) 
 Global Resource Directory frozen
* dead instance detected - domain 1 invalid = TRUE 
 Communication channels reestablished
 Master broadcasted resource hash value bitmaps
 Non-local Process blocks cleaned out
Tue Jun 16 09:24:51 2020
 LMS 0: 0 GCS shadows cancelled, 0 closed, 0 Xw survived
 Set master node info 
 Submitted all remote-enqueue requests
 Dwn-cvts replayed, VALBLKs dubious
 All grantable enqueues granted
 Post SMON to start 1st pass IR
Tue Jun 16 09:24:51 2020
NOTE: SMON starting instance recovery for group DATA domain 1 (mounted)
NOTE: F1X0 found on disk 0 au 2 fcn 0.31174920
 Submitted all GCS remote-cache requests
 Post SMON to start 1st pass IR
 Fix write in gcs resources
Reconfiguration complete
NOTE: starting recovery of thread=2 ckpt=709.4758 group=1 (DATA)
NOTE: SMON waiting for thread 2 recovery enqueue
NOTE: SMON about to begin recovery lock claims for diskgroup 1 (DATA)
NOTE: SMON successfully validated lock domain 1
NOTE: advancing ckpt for group 1 (DATA) thread=2 ckpt=709.4758
NOTE: SMON did instance recovery for group DATA domain 1
Tue Jun 16 09:27:16 2020
Reconfiguration started (old inc 18, new inc 20)
List of instances:
 1 2 (myinst: 1) 
 Global Resource Directory frozen
 Communication channels reestablished
 Master broadcasted resource hash value bitmaps
 Non-local Process blocks cleaned out
Tue Jun 16 09:27:16 2020
 LMS 0: 0 GCS shadows cancelled, 0 closed, 0 Xw survived
 Set master node info 
 Submitted all remote-enqueue requests
 Dwn-cvts replayed, VALBLKs dubious
 All grantable enqueues granted
 Submitted all GCS remote-cache requests
 Fix write in gcs resources
Reconfiguration complete
