# <center>ss_server配置内容<center>

### 说明：该记录是自己在搭建ss服务器的时候做的一些安全防护。

## 一、时间配置
    yum install ntpdate -y
    timedatectl set-timezone Asia/Shanghai
    cat > /opt/ntp.sh << EOF
    #!/bin/bash
    /usr/sbin/ntpdate 1.cn.pool.ntp.org > /dev/null
    /sbin/clock -w
    EOF
    crontab -e
    59 23 * * 0 /usr/bin/bash /opt/ntp.sh
    crontab -l

## 二、防止暴力破解ssh
> ```ssh_login_protection.sh```脚本已上传至Github中。

## 三、登陆提示
    cat > /etc/motd << EOF 
                                      _oo0oo_
                                     088888880
                                     88" . "88
                                     (| -_- |)
                                      0\ = /0
                                   ___/‘---‘\___
                                 .‘ \\|     |// ‘.
                                / \\|||  :  |||// \ 
                              | \_|  ‘‘\---/‘‘  |_/ |
                              \  .-\__  ‘-‘  __/-.  /
                            ___‘. .‘  /--.--\  ‘. .‘___
                         ."" ‘<  ‘.___\_<|>_/___.‘ >‘  "".
                        | | : ‘-  \‘.;‘\ _ /‘;.‘/ - ‘ : | |
                        \  \ ‘_.   \_ __\ /__ _/   .-‘ /  /
                    =====‘-.____‘.___ \_____/___.-‘____.-‘=====
                                      ‘=---=‘
      
      
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                            妖魔鬼怪    iii    速速离开
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    EOF

## 四、登陆邮件通告
#### 1、安装nali，实现对ip归属地的显示
    tar xf nali-0.2.tar.gz
    cd nali-0.2
    ./configure && make && make install && nali-update
#### 2、配置ssh登陆调用脚本
    cat > /etc/ssh/sshrc << EOF
    #!/bin/sh
    /usr/bin/bash /opt/user_login_notice.sh
    EOF

> ```/opt/user_login_notice.sh```脚本已上传至Github中。  
```/opt/mail.py```脚本已上传至Github中，根据脚本注释填写邮件服务器、账号、密码。  
```nali-0.2.tar.gz```已上传至Github中。  
*nali备用1：http://www.dwhd.org/wp-content/uploads/2015/08/nali-0.2.tar.gz*  
*nali备用2：https://drive.google.com/open?id=1HsZbeL1_4avnY8SXZH63H9CBo20TCsec*

## 五、web目录文件篡改检测
```web_file_check.sh```主脚本（有BUG）
```web_check_log_seg.sh```日志分割脚本
```web_mes_send.sh```篡改邮件通告脚本

## 六、计划任务
```crontab```

## 七、双重认证
#### 1、使用yum安装google-authenticator  
```yum install epel-release google-authenticator pam-devel -y```  
*补充：编译安装google-authenticator：https://github.com/google/google-authenticator-libpam/*  
#### 2、直接在shell命令行上运行：```google-authenticator```,下面一路```yes```即可
> 运行前保证当前linux主机时间和安卓客户端的时间都是一致的。  
运行后会有密钥和紧急验证码，记得手动保存。
#### 3、在安卓或苹果手机上安装Google身份验证器，输入上面的密钥，即可看到30秒后不断变化的一次性密码
> ```com.google.android.apps.authenticator2.apk```已上传至Github中。  
*google-authenticator备用：https://drive.google.com/open?id=17tG3tqqoKZYzHCZHV76cUJOJVf6aeC15*  
#### 4、在Linux主机上加载google身份验证模块
```vim /etc/pam.d/sshd```  
直接添加：  
```auth required pam_google_authenticator.so```  
启用ssh的ChallengeResponseAuthentication：  
```vim /etc/ssh/sshd_config```  
```ChallengeResponseAuthentication yes```  
```systemctl restart sshd```  

## 八、补充
#### 补充1：ssh爆破脚本

> ```/opt/ssh_crack.sh```脚本已上传至Github中。  
```/opt/wordlist.txt```字典已上传至Github中。  
ssh_crack.sh脚本需要安装```sshpass```rpm包。  
```sshpass-1.05-9.1.x86_64.rpm```已上传至Github中。  
*sshpass备用：https://drive.google.com/open?id=1Oe3dJpGguL8q35ZVYDJjtcD8PYreBXJV*
#### 补充2：报错备注
    1、shell中“!”号的问题
    [root@lifa ~]# head="Notification: Lifa_ss_Server has a new connection!\n"
    -bash: !\n": event not found
    解法1：
    [root@lifa ~]# head="Notification: Lifa_ss_Server has a new connection.\n"
    解法2：
    [root@lifa ~]# head="Notification: Lifa_ss_Server has a new connection\!\n"
    参考：https://blog.csdn.net/wo541075754/article/details/51222655
    
    2、无法退出shell
    [root@lifa opt]# exit
    logout
    There are stopped jobs.
    [root@lifa opt]# ls
    login_notice.sh  mail.py  ntp.sh
    [root@lifa opt]# exit
    logout
    There are stopped jobs.
    [root@lifa opt]# jobs -l
    [1]+ 24660 Stopped                 python
    [root@lifa opt]# kill %1
    
    [1]+  Stopped                 python
    [root@lifa opt]# 
    参考：https://blog.csdn.net/whaoxysh/article/details/17303513



