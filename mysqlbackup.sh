#!/bin/bash
#
#
###########DUMP MYSQL############

USER="root"
PASSWD="123456"
HOST="localhost"
MYSQL="/usr/local/mysql/bin/mysql"
MYSQLDUMP="/usr/local/mysql/bin/mysqldump --default-character-set=gbk --opt"
DATE=`date -I`
BACKUP="/var/backup"
DATABASES=`$MYSQL -u$USER -p$PASSWD -h$HOST  -Bse "show databases"|grep -Ev "(mysql|info|test|schema)" `
for i in $DATABASES 
do
    if [ ! -d $BACKUP/$DATE ] ; then
	mkdir $BACKUP/$DATE
    fi
	echo -e "Now dump $i"
	$MYSQLDUMP -u$USER -p$PASSWD $i | gzip >  $BACKUP/$DATE/$i.sql.gz

done
cd $BACKUP
#find ./ -ctime +5 -exec rm -rf {} \;
