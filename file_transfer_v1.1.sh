<<!
 ******************************************************************
 *Author       : Lifa
 *Last modified: 2018-11-23 13:51
 *Email        : 991179382@qq.com
 *Filename     : file_transfer.sh
 *Version      : v1.1
 *Description  : 
 *Usage: sh file_transfer.sh host_file src_file dest_file password
 *Just type the IP in host_file as follows:
[root@hostname ~]# cat host 
10.203.32.141
10.203.32.142
10.203.32.143
 *****************************************************************
!


#!/bin/bash
clear

host_file=$1
src_file=$2
dest_file=$3
password=$4

if [ $# -eq 0 ];then
echo "----------------------------------------------------------------------------------"
echo -e "|                             No \033[31mparameters\033[0m are specified!                        |"
echo "|          Usage: sh $0 host_file src_file dest_file password            |"
echo "----------------------------------------------------------------------------------"
exit 1
elif [ ! "$host_file" ];then
echo "----------------------------------------------------------------------------------"
echo -e "|                             No \033[31mhost_file\033[0m is specified!                         |"
echo "|          Usage: sh $0 host_file src_file dest_file password           |"
echo "----------------------------------------------------------------------------------"
exit 1
elif [ ! "$src_file" ];then
echo "----------------------------------------------------------------------------------"
echo -e "|                             No \033[31msrc_file\033[0m is specified!                           |"
echo "|          Usage: sh $0 host_file src_file dest_file password            |"
echo "----------------------------------------------------------------------------------"
exit 1
elif [ ! "$dest_file" ];then
echo "----------------------------------------------------------------------------------"
echo -e "|                             No \033[31mdest_file\033[0m is specified!                         |"
echo "|          Usage: sh $0 host_file src_file dest_file password           |"
echo "----------------------------------------------------------------------------------"
exit 1
elif [ ! "$password" ];then
echo "----------------------------------------------------------------------------------"
echo -e "|                             No \033[31mpassword\033[0m is specified!                          |"
echo "|          Usage: sh $0 host_file src_file dest_file password           |"
echo "----------------------------------------------------------------------------------"
exit 1
fi


check_ip() {
if [ "$1" ] && [[ "$1" =~ ^[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}$ ]];then
    echo "ip is ok" > /dev/null
	return 0
else
    echo "ip error" > /dev/null
	return 1
fi
}

init()
{
cat $host_file | while read line
do
   host_ip=`echo $line | awk '{print $1}'`
   if ! check_ip $host_ip;then
   echo -e "\e[4;31mFailed:[$host_ip]\e[0m(\e[4;33m[$host_ip]\e[0m is error)"
       continue
   fi
   username="root"
   password="$password"
#   echo "Sending..."
   transfer $host_ip $username $password $src_file $dest_file &>/dev/null
    if [ $? -eq 0 ];then
        echo -e "\e[4;32mSuccessful:[$host_ip]\e[0m"
    else
	    echo -e "\e[4;31mFailed:[$host_ip]\e[0m"
   fi
done
}

transfer()
{
/usr/bin/expect <<-EOF
set timeout -1
set host_ip [lindex $argv 0]
set username [lindex $argv 1]
set password [lindex $argv 2]
set src_file [lindex $argv 3]
set dest_file [lindex $argv 4]
spawn scp $src_file $username@$host_ip:$dest_file
 expect {
 "(yes/no)?"
  {
  send "yes\n"
  expect "*assword:" { send "$password\n"}
 }
 "*assword:"
{
 send "$password\n"
}
}
expect "100%"
expect eof
EOF
}


init
