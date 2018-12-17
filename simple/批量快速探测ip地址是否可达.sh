#!/bin/bash
for ip in `seq 130 149`
do
    ping 10.203.32.$ip -c 1 -w 1 &>/dev/null
    if [ $? -eq 0 ];then
        echo "$ip is ok"
    else
        echo "$ip is not"
    fi
done
