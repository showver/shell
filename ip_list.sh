<<!
 **********************************************************
 * Author        : Lifa
 * Email         : 991179382@qq.com
 * Last modified : 2018-11-27 10:33
 * Filename      : ip_list.sh
 * Description   : 查看系统所有网卡的ip、mac地址
 * *******************************************************
!

#!/bin/bash
clear
array=($(ls /sys/class/net))    #查看当前系统的网卡接口
for i in ${array[*]}
do
  ip=`ifconfig $i | grep -w "inet" | awk '{print $2}'`
  netmask=`ifconfig $i | grep -w "inet" | awk '{print $4}'`
  mac=`ifconfig $i | grep -w "ether" | awk '{print $2}'`
  if [ -z "$ip" ];then   
#-z：若字符串为空则if表达式为真
#if中判断字符串是否为空：https://www.cnblogs.com/ariclee/p/6137456.html
    ip="NULL"
  fi
  if [ -z "$netmask" ];then
    netmask="NULL"
  fi
  if [ -z "$mac" ];then
    mac="NULL"
  fi
  echo -e "\e[4;32m[$i]\e[0m:"
  echo "IPADDR:$ip"
  echo "NETMASK:$netmask"
  echo "MACADDR:$mac"
  echo "********************"
done

