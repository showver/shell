#!/bin/bash
#批量创建账户并随机生成8位数密码
USER="lifa"      #定义用户名
USER_NUM="10"    #定义用户数量
NO_LOGIN="0"     #是否允许用户登陆系统：0则不允许，其他数字则允许

#数字密码
pass_num()
{
#密码是1-9内随意组合成的8位数
pass=""
for ((i=1;i<9;i++))
do
    pass="$pass""$(($RANDOM%9+1))"
done
}

#英文大小写数字密码
pass_case()
{
    A=`head -c 500 /dev/urandom | tr -dc A-Z |head -c 1`          #随机生成500字符|只取大写字母|取第一个字符
    B=`head -c 500 /dev/urandom | tr -dc [:alnum:]| head -c 6`    #随机生成500字符|取英文大小写字节及数字，亦即 0-9, A-Z, a-z|取6位
    C=`echo $RANDOM$RANDOM|cut -c 2`                              #取第二位随机数字,第一位随机性不高大多数是1或2,所以取第二位.
    pass=`echo $A$B$C`
}

#创建账户
user_create()
{
if [ $NO_LOGIN -eq 0 ];then
      useradd $user -s /sbin/nologin
  else
      useradd $user
fi
}

clear
echo -e "请选择密码强度：\n1.数字密码\n2.英文大小写数字密码"
read num
case "$num" in
    1)
for i in `seq 1 $USER_NUM`
do
  user="$USER${i}"
  user_create
  pass_num
  echo "$pass" | passwd --stdin $user
  echo "create $user success and the password is $pass"
done
    ;;
    2)
for i in `seq 1 $USER_NUM`
do
  user="$USER${i}"
  user_create
  pass_case
  echo "$pass" | passwd --stdin $user
  echo "create $user success and the password is $pass"
done
    ;;
    *)
    echo "Input error!"
    exit 1
    ;;
  esac

