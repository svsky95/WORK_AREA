--https://mp.weixin.qq.com/s/DNPLi5cOyHbDId8WOygfXQ

#!/bin/bash
source ~/.bash_profile
BASE_DIR=/data/backup
MONGO=/usr/local/mongodb/bin/mongo
MONGO_DUMP=/usr/local/mongodb/bin/mongodump
MONGO_PORT=27017
MONGO_HOST=127.0.0.1
LOG=oplog_backup.log
OPLOG_TS_FILE=last_oplog_ts
CUR_TIME=`date`
DB_IP=`/sbin/ip a | grep eth0 | grep inet |awk '{print $2}' | cut -d'/' -f1 | head -1`
BACKUP_TIME=`date +%Y%m%d%H%M`
DB_BACKUP_NAME=oplog_${DB_IP}_${BACKUP_TIME}.tar.gz
BACKUP_TMP_DIR=${BACKUP_TIME}
THRESHOLD=1200
KEEP_DAY=7
 
do_exit(){
  if[ $? -eq 0 ]; then
       exit 0
 else
     #根据各自环境的实际监控逻辑自行实现
       exit 1
  fi
}
 
 
oplog_backup(){
 $MONGO_DUMP -h $MONGO_HOST:$MONGO_PORT -u backup -p *******--authenticationDatabase "admin" -d local -c oplog.rs  --gzip  -o $BACKUP_TMP_DIR
  
  if[ $? -ne 0 ]; then
       rm -rf $BACKUP_TMP_DIR
       sleep 60
       $MONGO_DUMP -h $MONGO_HOST:$MONGO_PORT -u backup -p *******--authenticationDatabase "admin" -d local -c oplog.rs  --gzip  -o $BACKUP_TMP_DIR
       do_exit
  fi
 
  tar-zcvf $DB_BACKUP_NAME $BACKUP_TMP_DIR
 do_exit
  rm-rf $BACKUP_TMP_DIR
}
 
if [ ! -d "$BASE_DIR" ]; then
       mkdir "$BASE_DIR"
fi
cd $BASE_DIR
 
#last_oplog_ts not exists, create it andtake an oplog backup
if [ ! -f "$OPLOG_TS_FILE" ];then
       $MONGO -u backup -p ******* --authenticationDatabase admin --port"$MONGO_PORT" --eval "rs.printReplicationInfo()" | grep'oplog last event' | cut -d' ' -f7,8,9,10,11,12 > $OPLOG_TS_FILE
       do_exit
       echo "`date ` $OPLOG_TS_FILE not exists, initiate it and take anoplog backup" >> $LOG
       oplog_backup
       echo "`date` oplog backup succeed" >> $LOG
        exit 0
fi
 
LAST_EVENT=$(cat $OPLOG_TS_FILE)
#last_oplog_ts is empty and has nolast_event, the oplog backup fails and exits
if [ ! -n "$LAST_EVENT" ];then 
       echo 1 > /data/backup/dumperr.log
       echo "`date` LAST_EVENT in $OPLOG_TS_FILE is NULL and oplog backupfails" >> $LOG
       exit 1
fi
 
#caculate the diff in seconds, and take anoplog backup when it's lower than the threshold
FIRST_EVENT=`$MONGO -u backup -p *******--authenticationDatabase admin --port "$MONGO_PORT" --eval"rs.printReplicationInfo()" | grep 'oplog first event' | cut -d' '-f7,8,9,10,11,12`
E1=$(date '+%s' -d"${LAST_EVENT}")
E2=$(date '+%s' -d"${FIRST_EVENT}")
DIFF=`expr $E1 - $E2`
echo "the time diff now is ${DIFF}sand the threshold is ${THRESHOLD}s"
 
if [ $DIFF -lt $THRESHOLD ]; then
       echo "`date` the diff is lower than ${THRESHOLD}, take an oplogbackup" >> $LOG
       $MONGO -u backup -p ******* --authenticationDatabase admin --port"$MONGO_PORT" --eval "rs.printReplicationInfo()" | grep'oplog last event' | cut -d' ' -f7,8,9,10,11,12 > $OPLOG_TS_FILE
       do_exit
       oplog_backup
       echo "`date` oplog backup succeed" >> $LOG
fi


find $BASE_DIR -name"oplog_${DB_IP}*" -mtime +${KEEP_DAY} | xargs rm -rf