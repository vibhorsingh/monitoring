#!/bin/sh

IFS=$'\n'

## This file will capture the output of top command
LOGFILE=/tmp/load_server1.txt

COUNTER=1

## remove the file if already existing
rm -rf $LOGFILE


## make sure sqlite3 is installed on you system
## The table structure for storing the data is pretty simple which has fields corresponding to:
## - serverIP
## - load average for 5 mins (load1), 10 mins(load2) and 15 mins(load3)
## - RAM usage
## - time when this data is captured

## we create the table if not already existing.
sqlite3 /path/to/your/sqlitedb <<EOS
CREATE TABLE IF NOT EXISTS server_load
             (server text, load1 REAL, load2 REAL, load3 REAL, memory INTEGER, created_time DATETIME);
EOS

## the following command get the IP address of the server from here this script is run
SERVER=`/sbin/ip -o -4 addr list em1 | awk '{print $4}' | cut -d/ -f1`


## variable 'mainload' captures the output of 'top' command. only first three lines are picked using grep command
mainload=`top -n 1 -b -d 1 | grep -n3 "load"`
s=''
k=''
for l in $mainload
do
	if [ "$COUNTER" -eq 1 ] ## get load data
	then
		echo $l | awk '{printf("%s%s%s",$12,$13,$14)}';
	fi
	
	if [ "$COUNTER" -eq 4 ]  ## get memory data
	then
		echo $l | awk '{printf(",%s",$4)}' | sed 's/k//';
	fi
	
	COUNTER=$((COUNTER+1))

done >> $LOGFILE	## store everything in a log file

date=$(date "+%Y-%m-%d %H:%M:%S")

vals=`cat $LOGFILE`

## finally save the contents in DB
sql="INSERT INTO server_load VALUES ('$SERVER',$vals,'$date')"

sqlite3 /path/to/your/sqlitedb $sql;
