<<!
 **********************************************************
 * Author        : Lifa
 * Email         : 991179382@qq.com
 * Last modified : 2018-11-27 10:33
 * Filename      : netspeed_mon.sh
 * Description   : 监控网速
 * *******************************************************
!


#!/bin/bash
clear
echo "This is all the network interfaces in your system:"
echo "--------------------------------------------------"
array=($(ls /sys/class/net))    #查看系统的网卡接口并将输出传入数组array中
for i in ${array[*]}    #for循环遍历输出每个数组中的变量
do
  echo -n "$i  "    #-n代表不换行输出
done
echo ""
echo "--------------------------------------------------"
echo -e "\e[4;32mPlease Choose the interface you want to monitor:\e[0m"
read interface
ethn=$interface

#判断用户输入的网卡接口名是否当前系统存在的方法1：（标志位）
array_sum=${#array[*]}
flag=0
for ((i=0;i<$array_sum;i++))
do
  if [ "$ethn" == "${array[i]}" ];then
    flag=0
	break
  else
    flag=1
  fi
done

if [ $flag -eq 1 ];then
  echo "[$ethn] is not in the system!"
  exit 1
fi

#判断用户输入的网卡接口名是否当前系统存在的方法2：（grep）
#if [ ! `ls /sys/class/net | grep -w "$ethn"` ];then
#  echo "[$ethn] is not in the system!"
#  exit 1
#fi

while true
do
 RX_pre=$(cat /proc/net/dev | grep $ethn | sed 's/:/ /g' | awk '{print $2}')
 TX_pre=$(cat /proc/net/dev | grep $ethn | sed 's/:/ /g' | awk '{print $10}')
 sleep 1
 RX_next=$(cat /proc/net/dev | grep $ethn | sed 's/:/ /g' | awk '{print $2}')
 TX_next=$(cat /proc/net/dev | grep $ethn | sed 's/:/ /g' | awk '{print $10}')

 RX=$((${RX_next}-${RX_pre}))
 TX=$((${TX_next}-${TX_pre}))
 
 if [[ $RX -lt 1024 ]];then
 RX="${RX}B/s"
 elif [[ $RX -gt 1048576 ]];then
 RX=$(echo $RX | awk '{print $interface/1048576 "MB/s"}')
 else
 RX=$(echo $RX | awk '{print $interface/1024 "KB/s"}')
 fi
 
 if [[ $TX -lt 1024 ]];then
 TX="${TX}B/s"
 elif [[ $TX -gt 1048576 ]];then
 TX=$(echo $TX | awk '{print $interface/1048576 "MB/s"}')
 else
 TX=$(echo $TX | awk '{print $interface/1024 "KB/s"}')
 fi

clear
 echo "Lifa's Network_Monitoring tool"
 echo "Time: $(date "+%Y-%m-%d %H:%M:%S")"
 echo "================================================="
 echo -e "Interface:[$ethn]"
 echo -e "RX:\e[1;34m$RX\e[0m TX:\e[1;34m$TX\e[0m"
 echo "================================================="
 echo "Tip: TX为上行流量(Transmit传送数据)、RX为下行流量(Receive接收数据)"
 echo ""
 echo "Press CTRL + C to exit..."
done

