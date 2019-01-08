<<!
 **********************************************************
 * Author        : Bingo
 * Email         : 991179382@qq.com
 * Last modified : 2019-01-08
 * Filename      : allexec.sh
 * System ENV    : rhel/centos/6/7
 * VERSION       : v1.1
 * Description   : Get hardware and software detail info on server/instance.
 * Remarks       : The system had better support megacli command
 **********************************************************
!

#!/bin/bash
host=$1
cmd=$2
username="root"
password="123456"
port="22"
timeout=3
for i in `cat $host`;
do
    result=""
    result=`sshpass -p "$password" ssh -p $port -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout $username@$i $cmd`
    echo -e "\e[32m Done \e[0m"
done

#执行教程：
#sh allexec.sh /root/host 'sh /tmxxx.sh -p /tmp/"$HOSTNAME"-result.xml'
