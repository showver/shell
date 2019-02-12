<<!
 **********************************************************
 * Author        : Bingo
 * Email         : 991179382@qq.com
 * Last modified : 2019-01-30
 * Filename      : web_file_check.sh
 * System ENV    : rhel/centos/6/7
 * VERSION       : v1.3
 * Description   : 
 * Remarks       : 该脚本的逻辑缺陷：当有某个文件被修改或删除或新增后，
 在计划任务中运行该脚本web_file_check.sh后，会将网站标志为WARNING，
 则后续的文件被篡改或者新增删除都无法记录，除非手动将echo "SAFE" > $WORK_DIR/if_web_safe.flag
 再执行该脚本web_file_check.sh查看文件被修改列表数
 **********************************************************
!

#重置脚本
#执行web_file_check.sh前请先将web目录的文件hash一遍
#Example:
#WORK_DIR="/opt"
#ls -Rla /var/www/html/data > $WORK_DIR/site_num.txt
#find /var/www/html/data/. -type f -print0 | xargs -0 md5sum > $WORK_DIR/checkmd5.db
#echo "SAFE" > $WORK_DIR/if_web_safe.flag

#!/bin/bash
WORK_DIR="/opt"                                 #工作目录
WEB_DIR="/var/www/html/data"                    #web目录
SITE_LIST_FILE="site_num.txt"                   #站点文件列表
MD5_DB_FILE="checkmd5.db"                       #站点文件hash数据库
IF_WEB_SAFE="if_web_safe.flag"                  #标志（该标志用于识别站点文件是否安全）
MESSAGE="message.txt"                           #信息文件，发送邮件用
WEB_FILE_CHECK_LOG=/tmp/web_check.log           #站点文件检测日志
TIME=`date +%F' '%H:%M:%S`                      #时间格式定义
flag="ok"                                       #标志

#判断标志文件是否存在
cd $WORK_DIR
if [ ! -f "$IF_WEB_SAFE" ];then
    echo "$IF_WEB_SAFE 不存在，请检查！"
    exit 1
fi
cat $WORK_DIR/$IF_WEB_SAFE | grep "WARNING" > /dev/null    #若网站不安全则不再执行下面的检测
if [ $? -eq 0 ];then
    exit 1
fi

#日志开始标志
echo "**************${TIME}****************************" >> $WEB_FILE_CHECK_LOG

#清空消息文件
echo "" > $WORK_DIR/$MESSAGE

#检测用户定义的路径、文件名是否存在or合法
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

#检测站点文件列表文件和站点文件hash数据库文件是否存在
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

#判断文件是否被更改
if_file_change()
{
array=($(find $WEB_DIR/. -type f))                                                   #将web目录下所有文件存放到数组中
for i in ${array[*]}
do
    file_md5_url=`md5sum $i`                                                         #hash文件（结果是hash值+文件全路径）
    file_md5=`echo $file_md5_url | awk '{print $1}'`                                 #取md5值
    source_file_md5=`cat $WORK_DIR/$MD5_DB_FILE | grep $i | awk '{print $1}'`        #取源文件的hash值
    if_file_in_db=`cat $WORK_DIR/$MD5_DB_FILE | grep $i`                             #检测hash数据库是否有该文件
    if [ -z "$if_file_in_db" ];then
        echo "${TIME} [ERROR] File $i is not in db"
        echo "${TIME} [ERROR] File $i is not in db" >> $WEB_FILE_CHECK_LOG
        echo "${TIME} [ERROR] File $i is not in db" >> $WORK_DIR/$MESSAGE
        flag="110"                                                                   #该文件不在数据库中，标志flag为110
        continue                                                                     #跳过下面的程序
    fi
    if [ "$file_md5" != "$source_file_md5" ];then                                    #检测当前文件的hash值与数据库中的是否一致
        echo "${TIME} [ERROR] File $i is change"
        echo "${TIME} [ERROR] File $i is change" >> $WEB_FILE_CHECK_LOG
        echo "${TIME} [ERROR] File $i is change" >> $WORK_DIR/$MESSAGE
        flag="110"                                                                   #hash值不一致，标志flag为110
    fi
done
if [ "$flag" = "110" ];then                                                          #判断flag标志是否为110，是的话则标记站点为不安全
    echo "WARNING" > $WORK_DIR/$IF_WEB_SAFE
fi
}

#判断文件是否有增减
if_file_add_or_del()
{
#获取当前站点文件列表
ls -Rla /var/www/html/data | awk '{print $9}' | grep -v '^$' > $WORK_DIR/now_site_num.txt
ls -Rla /var/www/html/data > $WORK_DIR/now_site_num2.txt

#从原始站点列表文件中遍历每行，与now_site_num.txt比对
while read line
do
    cat $WORK_DIR/now_site_num.txt | grep $line > /dev/null    #判断原始站点文件是否在当前站点文件列表中
#BUG子目录与根目录有同名文件的情况：当删除子目录或根目录该文件后，cat再grep会误判为存在
    state1="$?"
    if [ $state1 -ne 0 ];then                                  #不存在则说明当前web目录少了该文件
#BUG        file_url1=`cat $WORK_DIR/site_num2.txt | grep $line`   #BUG:无法获取丢失的文件的绝对路径
#BUG        file_path1=`echo ${file_url1%/*}`                      #BUG:无法获取丢失的文件所在目录
        echo "${TIME} [ERROR] $WEB_DIR missing $line"
        echo "${TIME} [ERROR] $WEB_DIR missing $line" >> $WEB_FILE_CHECK_LOG
        echo "${TIME} [ERROR] $WEB_DIR missing $line" >> $WORK_DIR/$MESSAGE
        echo "WARNING" > $WORK_DIR/$IF_WEB_SAFE
    fi
done < $WORK_DIR/site_num.txt

#从当前站点列表文件中遍历每行，与site_num.txt比对
while read line
do
    cat $WORK_DIR/site_num.txt | grep $line > /dev/null            #判断当前站点文件是否在原始站点文件列表中
    state2="$?"
    if [ $state2 -ne 0 ];then                                      #存在则说明当前web目录多了该文件
        file_url2=`find $WEB_DIR -name $line`                      #获取新增的文件的绝对路径
        file_path2=`echo ${file_url2%/*}`                          #获取新增的文件所在目录
        echo "${TIME} [ERROR] $file_path2 has added $line"
        echo "${TIME} [ERROR] $file_path2 has added $line" >> $WEB_FILE_CHECK_LOG
        echo "${TIME} [ERROR] $file_path2 has added $line" >> $WORK_DIR/$MESSAGE
        echo "WARNING" > $WORK_DIR/$IF_WEB_SAFE
    fi
done < $WORK_DIR/now_site_num.txt
}

#发送邮件脚本
send_message()
{
cat $WORK_DIR/$IF_WEB_SAFE | grep "WARNING" > /dev/null    #若网站不安全则不再执行下面的检测
if [ $? -eq 0 ];then
    message=`cat $WORK_DIR/$MESSAGE`
    python /opt/mail.py 11045771@qq.com "web_change" "$message"
elif [ "$flag" = "110" ];then
    message=`cat $WORK_DIR/$MESSAGE`
    python /opt/mail.py 11045771@qq.com "web_change" "$message"
else
    echo "${TIME} [INFO] WEB IS SAFE" >> $WEB_FILE_CHECK_LOG
    echo "SAFE" > $WORK_DIR/$IF_WEB_SAFE
fi
}


path_is_valid
if_file_exist
if_file_change
if_file_add_or_del
send_message
