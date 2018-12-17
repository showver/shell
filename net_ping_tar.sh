<<!
 **********************************************************
 * Author        : Lifa
 * Email         : 991179382@qq.com
 * Last modified : 2018-09-26 10:33
 * Filename      : net_ping_tar.sh
 * Description   : 该脚本通过ping测试网络的连通性并输出到日志，每日归档
 * Remarks       : sh net_ping_tar.sh & 后台执行
 * *******************************************************
!

#!/bin/bash
IP=baidu.com                #IP&域名
dir="/tools/netdir/"
dir_status="`cd $dir >/dev/null 2>&1;echo $?`"
if [ $dir_status -ne 0 ];then
    mkdir -p ${dir}
fi

while true
do
    data=`date +%F' '%H:%M`
    data1=`date +%F' '%H:%M:%S`
    echo "------------${data1}---------------">>${dir}ping.log
    ping -c 5 ${IP} >>${dir}ping.log
    sleep 5
    
    Time=`date +%F`
    TIME="${Time} 23:59"
    if [ "${data}" == "${TIME}" ];then
        mkdir ${dir}${Time} && mv ${dir}ping.log ${dir}${Time}-ping.log
        mv ${dir}${Time}-ping.log ${dir}${Time}    #每晚23：59实现切割并以日期归档，日志保存7天
    fi
    find ${dir} -mtime +7 -name "*-ping.log" -exec rm -rf {} \;
done

#-mtime的理解：https://oracleblog.org/study-note/how-to-calculate-find-mtime/
