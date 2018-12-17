#!/bin/sh
#使用while计算1到100的和
num=1
sum=0
while [ $num -le 100 ];do
  sum=$(( $sum+$num ))
  num=$(( $num+1 ))
done
echo "1 to 100 sum is:$sum"
#注意：shell中的数值相加不能直接使用sum=$sum+1
