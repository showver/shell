#!/bin/bash

#变量定义
USER=root
PASS=123456
SHOW="mysql -u$USER -p$PASS"
DUMP="mysqldump -u$USER -p$PASS"
BAKPATH="/server/bak_db/$(date +%F)"
[ ! -d $BAKPATH ]&&mkdir -p $BAKPATH


clear
echo -e "请选择备份方式：\n1.分库\n2.分表"
read num
case "$num" in
    1)
      #分库
for dbname in `$SHOW -e 'show databases;'|sed '1d'|grep -v "_schema"`    #排除系统默认的数据库
do
  $DUMP -B -x $dbname | gzip > $BAKPATH/${dbname}.sql.gz
  if [ $? -eq 0 ];then
    echo "backup $dbname success!" > $BAKPATH/${dbname}.log
  fi
done
          ;;
    2)
      #分表
for dbname in `$SHOW -e 'show databases;'|sed '1d'|grep -v "_schema"`
do
  for tname in `$SHOW -e "show tables from $dbname;"|sed '1d'`    #注意，这里如果-e后的内容用''会识别不到变量$dbname
    do
      $DUMP -x $dbname $tname | gzip > $BAKPATH/${dbname}_${tname}.sql.gz
      if [ $? -eq 0 ];then
        echo "backup $dbname success!" > $BAKPATH/${dbname}_${tname}.log
      fi
  done
done
          ;;
    *)
      echo "Input error!"
      exit 1
      ;;
  esac

