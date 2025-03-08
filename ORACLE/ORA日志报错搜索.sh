TMP_DATE=`date |awk '{print $1,$2,$3}'`
TMP_ROW=`grep -n "Fri Apr 12" alert_snswtscx1.log |head -1  |nawk -F ':' '{print $1}'`

sed -n "${TMP_ROW},\$" p alert*.log|grep ORA-





TMP_ROW=`grep -n "Thu Jan 15" alert*.log |head -1  |nawk -F ':' '{print $1}'`


TMP_DATE=`date |awk '{print $1,$2,$3}'`

grep -n $TMP_DATE alert_sjyydb.log |head -1  |nawk -F ':' '{print $1}'