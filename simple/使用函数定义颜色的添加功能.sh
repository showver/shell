#!/bin/sh
#使用函数定义颜色的添加功能
add(){
RED_COLOR='\E[1;31m'
GREEN_COLOR='\E[1;32m'
YELLOW_COLOR='\E[1;33m'
BLUE_COLOR='\E[1;34m'
FLASH_COLOR='\33[5m'
RES='\E[0m'
case "$1" in
  red|RED)
         echo -e "$RED_COLOR $2 $RES"
         ;;
  green|GREEN)
         echo -e "$GREEN_COLOR $2 $RES"
         ;;
  yellow|YELLOW)
         echo -e "$YELLOW_COLOR $2 $RES"
         ;;
  blue|BLUE)
         echo -e "$BLUE_COLOR $2 $RES"
         ;;
         *)
         echo "plu use:{red|green|yellow|blue} {chars}"
         exit
esac
}

menu(){
cat <<END
=================
1.apple
2.pear
3.banana
4.cherry
5.exit
==================
END
}

fruit(){
read -p "pls input the fruit your like:" fruit
case "$fruit" in
    1)
      add red apple
    ;;
    2)
      add green pear
    ;; 
    3)
      add yellow banana
    ;;
    4)
      add blue cherry
    ;;
    5)
      exit
    ;;

    *)
      echo "pls select right num:{1|2|3|4}"
      exit
esac
}

main(){
 while true
 do
  menu
  fruit
 done
}
main
