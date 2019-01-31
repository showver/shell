<<!
 **********************************************************
 * Author        : Bingo
 * Email         : 991179382@qq.com
 * Last modified : 2019-01-31
 * Filename      : web_mes_send.sh
 * System ENV    : rhel/centos/6/7
 * VERSION       : v1.1
 * Description   : 
 * Remarks       : 
 **********************************************************
!

#!/bin/bash
WORK_DIR="/opt"
WEB_DIR="/var/www/html/data"
IF_WEB_SAFE="if_web_safe.flag"
MESSAGE="message.txt"

message=`cat $WORK_DIR/$MESSAGE`
echo "$message" | grep "ERROR" > /dev/null
if [ "$?" -eq 0 ];then
    python /opt/mail.py 11045771@qq.com "web_change" "$message"
else
    exit 1
fi



