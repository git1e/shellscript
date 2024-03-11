#!/bin/bash
###################################
#删除早于n天的ES集群的索引
###################################
delete_indices() {
    comp_date=`date -d "7 day ago" +"%Y-%m-%d"`
    date1="$1 00:00:00"
    date2="$comp_date 00:00:00"

    t1=`date -d "$date1" +%s`
    t2=`date -d "$date2" +%s`

    if [ $t1 -le $t2 ]; then
        echo "$1时间早于$comp_date，进行索引删除"
		curl -XGET http://172.20.201.136:9095/_cat/indices | awk -F" " '{print $3}' | grep $1 | \
		while read LINE
		do
			curl -XDELETE http://172.20.201.136:9095/$LINE
		done
    fi
}

curl -XGET http://172.20.201.136:9095/_cat/indices | \
awk -F" " '{print $3}' | awk -F"_" '{print $NF}' | \
egrep "[0-9]*\-[0-9]*\-[0-9]*" | sort | uniq | \
while read LINE
do
    #调用索引删除函数
    delete_indices $LINE
done

