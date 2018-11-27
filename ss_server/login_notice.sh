#!/bin/bash
head="Notification: Lifa_ss_Server has a new connection.\n"
detail1="Connector is `nali ${SSH_CLIENT%% *}`\n"
detail2="Logged in by $USER@`hostname`\n"
detail3="Logged in at `date +'%F %H:%M:%S'`\n"
message=`echo -e "$head$detail1$detail2$detail3"`

python /opt/mail.py xxxxxxxx@qq.com "Lifa_ss_Server" "$message"


#备注：
#\r：制表符
#\n：回车