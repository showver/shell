<<!
 **********************************************************
 * Author        : Bingo
 * Email         : 991179382@qq.com
 * Last modified : 2019-01-30
 * Filename      : web_file_check.sh
 * System ENV    : rhel/centos/6/7
 * VERSION       : v1.2
 * Description   : 
 * Remarks       : 
 **********************************************************
!

#重置脚本
#执行web_file_check.sh前请先将web目录的文件hash一遍
#Example:
#WORK_DIR="/opt"
#ls -la /var/www/html/data > $WORK_DIR/site_num.txt
#find /var/www/html/data/. -type f -print0 | xargs -0 md5sum > $WORK_DIR/checkmd5.db
#echo "SAFE" > $WORK_DIR/if_web_safe.flag

#!/bin/bash
WORK_DIR="/opt"
WEB_DIR="/var/www/html/data"
SITE_LIST_FILE="site_num.txt"
MD5_DB_FILE="checkmd5.db"
IF_WEB_SAFE="if_web_safe.flag"
MESSAGE="message.txt"
WEB_FILE_CHECK_LOG=/tmp/web_check.log
TIME=`date +%F' '%H:%M:%S` 
flag="ok"

cd $WORK_DIR
if [ ! -f "$IF_WEB_SAFE" ];then
    echo "$IF_WEB_SAFE 不存在，请检查！"
    exit 1
fi
cat $WORK_DIR/$IF_WEB_SAFE | grep "WARNING" > /dev/null
if [ $? -eq 0 ];then
    exit 1
fi

#日志开始标志
echo "**************${TIME}****************************" >> $WEB_FILE_CHECK_LOG

echo "" > $WORK_DIR/$MESSAGE

path_is_valid()
{
#WORK_DIR
echo "$WORK_DIR" | grep "^/" > /dev/null    #过滤用户输入的路径是否以“/”开头（绝对路径需要）
num1="$?"
if [ $num1 -ne 0 ];then
    echo -e "\e[31m Please use the absolute path. \e[0m"
    echo "${TIME} [ERROR] Please use the absolute path." >> $WEB_FILE_CHECK_LOG    #记录到日志
    exit 1
elif [ ! -d "$WORK_DIR" ];then
    echo "$WORK_DIR 不存在，请检查！"
    echo "${TIME} [ERROR] $WORK_DIR 不存在，请检查！" >> $WEB_FILE_CHECK_LOG
    exit 1
fi
#WEB_DIR
echo "$WEB_DIR" | grep "^/" > /dev/null    #过滤用户输入的路径是否以“/”开头（绝对路径需要）
num2="$?"
if [ $num2 -ne 0 ];then
    echo -e "\e[31m Please use the absolute path. \e[0m"
    echo "${TIME} [ERROR] Please use the absolute path." >> $WEB_FILE_CHECK_LOG    #记录到日志
    exit 1
elif [ ! -d "$WEB_DIR" ];then
    echo "$WEB_DIR 不存在，请检查！"
    echo "${TIME} [ERROR] $WEB_DIR 不存在，请检查！" >> $WEB_FILE_CHECK_LOG
    exit 1
fi
}

if_file_exist()
{
cd $WORK_DIR
if [ ! -f "$SITE_LIST_FILE" ];then
    echo "$SITE_LIST_FILE 不存在，请检查！"
    echo "${TIME} [ERROR] $SITE_LIST_FILE 不存在，请检查！" >> $WEB_FILE_CHECK_LOG
    exit 1
fi
if [ ! -f "$MD5_DB_FILE" ];then
    echo "$MD5_DB_FILE 不存在，请检查！"
    echo "${TIME} [ERROR] $MD5_DB_FILE 不存在，请检查！" >> $WEB_FILE_CHECK_LOG
    exit 1
fi
}

#判断文件是否被更改v2
if_file_change()
{
array=($(find $WEB_DIR/. -type f))    #查看当前系统的网卡接口
for i in ${array[*]}
do
    file_md5_url=`md5sum $i`
    file_md5=`echo $file_md5_url | awk '{print $1}'`
    source_file_md5=`cat $WORK_DIR/$MD5_DB_FILE | grep $i | awk '{print $1}'`
    if_file_in_db=`cat $WORK_DIR/$MD5_DB_FILE | grep $i`
    if [ -z "$if_file_in_db" ];then
        echo "${TIME} [ERROR] File $i is not in db"
        echo "${TIME} [ERROR] File $i is not in db" >> $WEB_FILE_CHECK_LOG
        echo "${TIME} [ERROR] File $i is not in db" >> $WORK_DIR/$MESSAGE
        flag="110"
        continue
    fi
    if [ "$file_md5" != "$source_file_md5" ];then
        echo "${TIME} [ERROR] File $i is change"
        echo "${TIME} [ERROR] File $i is change" >> $WEB_FILE_CHECK_LOG
        echo "${TIME} [ERROR] File $i is change" >> $WORK_DIR/$MESSAGE
        flag="110"
    fi
done
}

#判断文件是否有增减
if_file_add_or_del()
{
num=`cat $WORK_DIR/$SITE_LIST_FILE | wc -l`        #从原始文件列表中获取web目录下的文件个数
filenum=`ls -la $WEB_DIR | wc -l`                  #计算当前web目录下文件个数
if [ $filenum -ne $num ];then
    echo "${TIME} [ERROR] $WEB_DIR dir may add or del some files/dir"
    echo "${TIME} [ERROR] $WEB_DIR dir may add or del some files/dir" >> $WEB_FILE_CHECK_LOG
    echo "${TIME} [ERROR] $WEB_DIR dir may add or del some files/dir" >> $WORK_DIR/$MESSAGE
    echo "WARNING" > $WORK_DIR/$IF_WEB_SAFE
    message=`cat $WORK_DIR/$MESSAGE`
    python /opt/mail.py 11045771@qq.com "web_change" "$message"
else
    if [ "$flag" = "110" ];then
        echo "WARNING" > $WORK_DIR/$IF_WEB_SAFE
        message=`cat $WORK_DIR/$MESSAGE`
        python /opt/mail.py 11045771@qq.com "web_change" "$message"
        break
	else
        echo "${TIME} [INFO] WEB IS SAFE" >> $WEB_FILE_CHECK_LOG
        echo "SAFE" > $WORK_DIR/$IF_WEB_SAFE
    fi
fi
}

path_is_valid
if_file_exist
if_file_change
if_file_add_or_del
