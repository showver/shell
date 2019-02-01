#/bin/bash

WEB_FILE_CHECK_LOG=/tmp/web_check.log
TIME=`date +%F` 
LIMIT=8192
log_size=`du -sk $WEB_FILE_CHECK_LOG | awk '{print $1}'`
if [ $log_size -ge $LIMIT ];then
    mv $WEB_FILE_CHECK_LOG /tmp/web_check-${TIME}.log
fi

find /tmp -mtime +15 -name "web_check-*" -exec rm -rf {} \;
