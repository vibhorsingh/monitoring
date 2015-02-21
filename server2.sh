#!/bin/sh

LOGFILE=/tmp/load_server2.txt
rm -rf $LOGFILE
SERVER=`/sbin/ip -o -4 addr list lo | awk '{print $4}' | cut -d/ -f1`
IFS=$'\n'
COUNTER=1
mainload=`top -n 1 -b -d 1 | grep -n3 "load"`
s=''
k=''
for l in $mainload
do
	if [ "$COUNTER" -eq 1 ] 
	then
		echo $l | awk '{printf("%s%s%s",$12,$13,$14)}';
	fi
	
	if [ "$COUNTER" -eq 4 ] 
	then
		echo $l | awk '{printf(",%s",$4)}' | sed 's/k//';
	fi
	
	COUNTER=$((COUNTER+1))

done >> $LOGFILE

date=$(date "+%Y-%m-%d %H:%M:%S")

vals=`cat $LOGFILE`

sql="INSERT INTO server_load VALUES ('$SERVER',$vals,'$date')"

echo $sql
