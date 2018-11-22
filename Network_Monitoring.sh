<<!
 **********************************************************
 * Author        : Lifa
 * Email         : 991179382@qq.com
 * Last modified : 2018-07-26 10:33
 * Filename      : Network_Monitoring.sh
 * Description   : 
 * *******************************************************
!


#!/bin/bash
echo "----------------------------------------------------------------------------------------------------"
echo "          This is all the network interfaces in your system!                    "
echo "$(ip link)"
echo "----------------------------------------------------------------------------------------------------"
echo -e "\e[4;32mPlease Choose the interface you want to monitor:\e[0m"
read interface
ethn=$interface
 
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
 echo "Lifa's network interface traffic monitoring tool"
 echo "Now the time is $(date "+%Y-%m-%d %H:%M:%S")"
 echo "============================================="
 echo -e "Interface:$ethn"
 echo -e "RX:\e[1;34m$RX\e[0m TX:\e[1;34m$TX\e[0m"
 echo "=============================================="
 echo "Tip1: Press CTRL + C to exit!"
 echo "Tip2: TX为上行流量、RX为下行流量"
 echo "TX代表传送数据，RX是接收数据"
 echo "Transmit 和 Receive 的缩写"

done

