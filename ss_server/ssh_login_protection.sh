<<!
 **********************************************************
 * Author        : Lifa
 * Email         : 991179382@qq.com
 * Last modified : 2018-11-27 17:33
 * Filename      : ssh_login_protection.sh
 * Description   : 登陆失败5次后禁止该ip再次登陆，防止暴力破解ssh
 * *******************************************************
!

#!/bin/bash
cat /var/log/secure | awk '/Authentication failure/{print $(NF)}'|sort|uniq -c|awk '{print $2"="$1;}' > /opt/black.list
for i in `cat /opt/black.list`
    do
      IP=`echo $i |awk -F= '{print $1}'`
      NUM=`echo $i|awk -F= '{print $2}'`
      if [ ${#NUM} -gt 5 ]; then
        grep $IP /etc/hosts.deny > /dev/null
        if [ $? -gt 0 ];then
          echo "sshd:$IP:deny" >> /etc/hosts.deny
        fi
      fi
    done

#脚本中过滤日志“Authentication failure”需要根据系统实际的情况做相应变动。
#该脚本需要写成计划任务
#crontab -e
#1 * * * 0 /usr/bin/bash ssh_login_protection.sh
#crontab -l
