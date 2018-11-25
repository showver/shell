"""
 **********************************************************
 * Author        : Lifa
 * Email         : 991179382@qq.com
 * Last modified : 2018-11-13 17:28
 * Filename      : mail.py
 * Description   : 
 * *******************************************************
"""


#!/usr/bin/python
# -*- coding: UTF-8 -*-
#qq ssl mail

import os,sys
reload(sys)
sys.setdefaultencoding('utf8')
import smtplib
from email.mime.text import MIMEText
from email.utils import formataddr
 
my_sender='xxxxxxx@qq.com'    # 发件人邮箱账号
my_pass='xxxxxxxxxxxxxxx'     # 发件人邮箱密码
my_user='xxxxxxx@qq.com'      # 收件人邮箱账号
def mail(to,subject,content):
    ret=True
    try:
        msg=MIMEText(content,'plain','utf-8')
        msg['From']=formataddr(["Lifa_ss_Server",my_sender])    # 括号里的对应发件人邮箱昵称、发件人邮箱账号
        msg['To']=formataddr(["NET_Lifa",to])
        msg['Subject']=subject                                  # 邮件的主题，也可以说是标题
 
        server=smtplib.SMTP_SSL("smtp.qq.com", 465)             # 发件人邮箱中的SMTP服务器，这里使用ssl
        server.login(my_sender, my_pass)                        # 括号中对应的是发件人邮箱账号、邮箱密码
        server.sendmail(my_sender,[my_user,],msg.as_string())   # 括号中对应的是发件人邮箱账号、收件人邮箱账号、发送邮件
        server.quit()     # 关闭连接
    except Exception:     # 如果 try 中的语句没有执行，则会执行下面的 ret=False
        ret=False
    return ret

def main():
    to=sys.argv[1]
    subject=sys.argv[2]
    content=sys.argv[3]
    #print to
    ret=mail(to,subject,content)
    if ret:
           print(".0:Attention:你的登陆信息已经通过邮件通知！")
    else:
           print(".1:Attention:你的登陆信息已经通过邮件通知！")

if __name__ == "__main__":
    main()

