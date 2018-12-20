#!/bin/sh
#使用函数、传参的方法判断一个网址是否可通
web_check(){
num=`curl -I -s -w "%{http_code}\n" $1 | head -1 | grep "\b200\b" | wc -l`
if [ $num -eq 1 ];then
    echo "web is ok"
    return 0
else
    echo "not ok"
    return 1
fi
}

while true
do
  clear
  read -p "please input an url:" url
  if [ ! -n "$url" ];then
      echo "you must input an url!"
      sleep 2
      clear
  else
      web_check $url
      exit 0
  fi
done
