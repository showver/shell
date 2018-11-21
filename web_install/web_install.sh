#!/bin/bash
# ******************************************************
# Author       : Lifa
# Last modified: 2018-07-20 13:51
# Email        : 991179382@qq.com
# Filename     : web_install.sh
# Description  : 
# Usage: sh web_install.sh
# ******************************************************


#judge script format
[ $# -ne 0 ]&&{
           echo "----------------------------------------------------------------------------------"
           echo "|          There is unnessary to have parameters behind the script!!!            |"
           echo "|                               USAGE:sh $0                                      |"
           echo "----------------------------------------------------------------------------------"
exit 1
}

#tip
tip()
{
seconds_left2=5
           echo "--------------------------------------------------------------------------"
           echo "|      Now you will init environment after $seconds_left2 seconds!                     |"
           echo "|                 请等待${seconds_left2}秒……                                             |"
           echo "--------------------------------------------------------------------------"
while [ $seconds_left2 -gt 0 ];do
echo -n $seconds_left2
sleep 1
seconds_left2=$(($seconds_left2 - 1))
echo -ne "\r     \r" #清除本行文字
done
}

#base_environment
base_environment()
{
#ssh_init
sed -i 's/.*UseDNS.*/UseDNS no/g' /etc/ssh/sshd_config
sed -i 's/.*GSSAPIAuthentication.*/GSSAPIAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/.*GSSAPIAuthentication.*/GSSAPIAuthentication no/g' /etc/ssh/ssh_config
sed -i 's/.*StrictHostKeyChecking.*/StrictHostKeyChecking no/g' /etc/ssh/ssh_config
service sshd reload
#selinux
sed -i 's/.*SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
#firewalld
systemctl stop firewalld
systemctl disable firewalld
#iptables
systemctl stop iptables
systemctl disable iptables
#NetworkManager
systemctl stop NetworkManager
systemctl disable NetworkManager
}

#init_mariadb
init_mariadb()
{
#mariadb
systemctl start mariadb
systemctl enable mariadb
#init_mariadb
sed -i "N;2ainit_connect='SET collation_connection = utf8_unicode_ci'" /etc/my.cnf
sed -i "N;2ainit_connect='SET NAMES utf8'" /etc/my.cnf
sed -i "N;2acharacter-set-server=utf8" /etc/my.cnf
sed -i "N;2acollation-server=utf8_unicode_ci" /etc/my.cnf
sed -i "N;2askip-character-set-client-handshake" /etc/my.cnf
sed -i "N;8adefault-character-set=utf8" /etc/my.cnf.d/client.cnf
sed -i "N;6adefault-character-set=utf8" /etc/my.cnf.d/mysql-clients.cnf

#这个关于数据库的初始化需要判断处理，否则再次运行脚本会出现问题。
mysql_secure_installation << EOF

y
Pass@word1
Pass@word1
y
y
y
y
EOF
mysql -uroot -pPass@word1 -e "grant all privileges on *.* to 'root'@'%' identified by 'Pass@word1'"
mysql -uroot -pPass@word1 -e "flush privileges"
}

#init_mysql5_7_24
init_mysql5_7_24()
{
#mysql5_7_24
systemctl start mysqld
systemctl enable mysqld
#init_mysql5_7_24
pass=`grep 'temporary password' /var/log/mysqld.log | awk -F ": " '{print $2}'`
mysql -uroot -p$pass --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Pass@word1';"
mysql -uroot -pPass@word1 --connect-expired-password -e "grant all privileges on *.* to 'root'@'%' identified by 'Pass@word1'"
mysql -uroot -pPass@word1 -e "flush privileges"
}

#finish
finish()
{

ip="$(/sbin/ifconfig|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}')"
clear
           echo "-------------------------------------------------------------------------------"
           echo "|                Initialization success!                                      |"
           echo -e "|           The Database user is :\e[4;32mroot\e[0m ,password is :\e[4;32mPass@word1\e[0m                     |"
           echo "|    Give Root User Logon Permission From Any Host!                           |"
           echo "-------------------------------------------------------------------------------"
}

#init_httpd
init_httpd()
{
#httpd.conf
cat > /etc/httpd/conf/httpd.conf << "EOF"
ServerRoot "/etc/httpd"
Listen 80
Include conf.modules.d/*.conf
User apache
Group apache
ServerAdmin root@localhost

<Directory />
    AllowOverride none
    Require all denied
</Directory>

DocumentRoot "/var/www/html"

<Directory "/var/www">
    AllowOverride None
    # Allow open access:
    Require all granted
</Directory>

<Directory "/var/www/html">
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
    CheckSpelling On
</Directory>

<IfModule dir_module>
    DirectoryIndex index.html index.php
</IfModule>

<Files ".ht*">
    Require all denied
</Files>

ErrorLog "logs/error_log"
LogLevel warn

<IfModule log_config_module>
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
    LogFormat "%h %l %u %t \"%r\" %>s %b" common

    <IfModule logio_module>
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
    </IfModule>
    CustomLog "logs/access_log" combined
</IfModule>

<IfModule alias_module>
    ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"
</IfModule>

<Directory "/var/www/cgi-bin">
    AllowOverride None
    Options None
    Require all granted
</Directory>

<IfModule mime_module>
    TypesConfig /etc/mime.types
    AddType application/x-compress .Z
    AddType application/x-gzip .gz .tgz
    AddType text/html .shtml
    AddOutputFilter INCLUDES .shtml
</IfModule>
AddDefaultCharset UTF-8

<IfModule mime_magic_module>
    MIMEMagicFile conf/magic
</IfModule>

EnableSendfile on
IncludeOptional conf.d/*.conf
EOF

#speling_mod
sed -i 's/.*speling_module.*/LoadModule speling_module modules\/mod_speling.so/g' /etc/httpd/conf.modules.d/00-base.conf
systemctl start httpd
systemctl enable httpd
}

#init_nginx
init_nginx()
{
#/etc/nginx/conf.d/default.conf
cat > /etc/nginx/conf.d/default.conf << "EOF"
server {
     listen       80;
     server_name  localhost;
     location / {
         root   /usr/share/nginx/html;
         index  index.php index.html index.htm;
     }   
     error_page   500 502 503 504  /50x.html;
     location = /50x.html {
         root   /usr/share/nginx/html;
     }   
     location ~ \.php$ {
         root           /usr/share/nginx/html;
         fastcgi_pass   127.0.0.1:9000;
         fastcgi_index  index.php;
         fastcgi_param  SCRIPT_FILENAME  $document_root/$fastcgi_script_name;
         include        fastcgi_params;  
     }   
}
EOF
#/etc/php-fpm.d/www.conf
sed -i 's/user = apache/user = nginx/g' /etc/php-fpm.d/www.conf
sed -i 's/user = apache/user = nginx/g' /etc/php-fpm.d/www.conf
systemctl start php-fpm
systemctl enable php-fpm
systemctl start nginx
systemctl enable nginx
}

#init_variable
init_variable()
{
#判断是否有配置相关的环境变量？
#judge MAVEN_HOME
grep -c "MAVEN_HOME" /etc/profile > /dev/null
if [ $? -eq '0' ]; then
    echo "The MAVEN_HOME variable has been configured!"
else
    cat >> /etc/profile << "EOF"
    #set for maven
    export MAVEN_HOME=/usr/local/src/maven
    export PATH=$PATH:$MAVEN_HOME/bin
EOF
fi
#judge NODE_HOME
if [ `grep -c "NODE_HOME" /etc/profile` -eq '1' ]; then
    echo "The NODE_HOME variable has been configured!"
else
    cat >> /etc/profile << "EOF"
    #set for nodejs
    export NODE_HOME=/usr/local/src/nodejs
    export PATH=$PATH:$NODE_HOME/bin
EOF
fi
source /etc/profile
}

#init_tomcat
init_tomcat()
{
cat > /usr/local/src/tomcat/conf/server.xml << "EOF"
<?xml version="1.0" encoding="UTF-8"?>
<Server port="8005" shutdown="SHUTDOWN">
  <Listener className="org.apache.catalina.startup.VersionLoggerListener" />
  <Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" />
  <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />
  <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" />
  <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />
  <GlobalNamingResources>
    <Resource name="UserDatabase" auth="Container"
              type="org.apache.catalina.UserDatabase"
              description="User database that can be updated and saved"
              factory="org.apache.catalina.users.MemoryUserDatabaseFactory"
              pathname="conf/tomcat-users.xml" />
  </GlobalNamingResources>
  <Service name="Catalina">
    <Connector port="80" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="8443" />
    <Connector port="8009" protocol="AJP/1.3" redirectPort="8443" />
    <Engine name="Catalina" defaultHost="localhost">
      <Realm className="org.apache.catalina.realm.LockOutRealm">
        <Realm className="org.apache.catalina.realm.UserDatabaseRealm"
               resourceName="UserDatabase"/>
      </Realm>

      <Host name="localhost"  appBase="webapps"
            unpackWARs="true" autoDeploy="true">
        <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
               prefix="localhost_access_log" suffix=".txt"
               pattern="%h %l %u %t &quot;%r&quot; %s %b" />
      </Host>
    </Engine>
  </Service>
</Server>
EOF
/usr/local/src/tomcat/bin/startup.sh
chmod +x /etc/rc.d/rc.local

#judge Tomcat startup.sh for rc.local
if [ `grep -c "startup.sh" /etc/rc.d/rc.local` -eq '1' ]; then
    echo "Tomcat startup.sh has been added!"
else
cat >> /etc/rc.d/rc.local << EOF
/usr/local/src/tomcat/bin/startup.sh
EOF
fi
}

clear
seconds_left=5
Dir_name="$(dirname $0)"
Base_name="$(basename $0)"
cd $Dir_name
           echo "---------------------------------------------------------------------------"
           echo "|    Attentios:This script is only suitable for rhel7/centos7 systems!    |"
           echo "---------------------------------------------------------------------------"
echo "Now the time is $(date "+%Y-%m-%d %H:%M:%S")"
echo "请等待${seconds_left}秒……"
while [ $seconds_left -gt 0 ];do
echo -n $seconds_left
sleep 1
seconds_left=$(($seconds_left - 1))
echo -ne "\r     \r" #清除本行文字
done

echo "Initialization success!"
echo "======================"
echo "1.[install lamp(mariadb5.5.56)+phpmyadmin]"
echo "2.[install lnmp(mariadb5.5.56)+phpmyadmin]"
echo "3.[install ltmj+maven+node]"
echo "4.[exit]"
echo "5.[install lamp(mysql5.7.24)+phpmyadmin]"
echo "6.[install lnmp(mysql5.7.24)+phpmyadmin]"
echo "======================"
read -p "Please choice a num:" num

#Determine if your input is empty
[ -z $num ]&&{
           echo "----------------------------------"
	   echo "|          Warning!!!            |"
	   echo "|   You must choice a num!       |"
	   echo "----------------------------------"
sh $Dir_name/web_install.sh
}

#Determine if your input is a num
expr $num + 1 &>/dev/null
RETVAL1=$?
[ $RETVAL1 -ne 0 ]&&{
           echo "----------------------------------"
           echo "|          Warning!!!            |"
           echo "|   Your input is not a num!     |"
           echo "----------------------------------"
exit 1
}

#case
case $num in
1){
echo "Installing lamp...Please waiting!"
yum localinstall -C -y --disablerepo=* $Dir_name/base/*.rpm $Dir_name/mariadb/*.rpm $Dir_name/httpd/*.rpm $Dir_name/php/*.rpm
[ $? -ne 0 ]&&{
clear
           echo "-----------------------------------------------------------------------------------"
           echo "|         Installation package failed!Please check the cause of failure!          |"
           echo "-----------------------------------------------------------------------------------"
exit 1
}
clear
           echo "------------------------------------"
           echo "|         Install Done!!!          |"
           echo "------------------------------------"
tip;
base_environment;
web_data=/var/www/html
tar -zxf $Dir_name/phpMyAdmin-4.8.1-all-languages.tar.gz -C $web_data
mv $web_data/phpMyAdmin-4.8.1-all-languages $web_data/phpmyadmin
init_mariadb;
finish;
init_httpd;
ip="$(/sbin/ifconfig|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}')"
echo -e "\e[4;32mYou can visit:http://$ip/phpmyadmin/index.php to manage your database!\e[0m"
exit 1
}
;;
2){
echo "Installing lnmp...Please waiting!"
yum localinstall -C -y --disablerepo=* $Dir_name/base/*.rpm $Dir_name/mariadb/*.rpm $Dir_name/nginx/*.rpm $Dir_name/httpd/*.rpm $Dir_name/php/*.rpm
[ $? -ne 0 ]&&{
clear
           echo "-----------------------------------------------------------------------------------"
           echo "|         Installation package failed!Please check the cause of failure!          |"
           echo "-----------------------------------------------------------------------------------"
exit 1
}
clear
           echo "------------------------------------"
           echo "|         Install Done!!!          |"
           echo "------------------------------------"
tip;
base_environment;
web_data=/usr/share/nginx/html
tar -zxf $Dir_name/phpMyAdmin-4.8.1-all-languages.tar.gz -C $web_data
mv $web_data/phpMyAdmin-4.8.1-all-languages $web_data/phpmyadmin
init_mariadb;
finish;
init_nginx;
ip="$(/sbin/ifconfig|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}')"
echo -e "\e[4;32mYou can visit:http://$ip/phpmyadmin/index.php to manage your database!\e[0m"
echo -e "\e[4;32mTip:Nginx web root:/usr/share/nginx/html/\e[0m"
exit 1
}
;;
3){
echo "Installing ltmj+maven+node...Please waiting!"
rpm -ivh $Dir_name/mtnj/*.rpm
[ $? -ne 0 ]&&{
clear
           echo "-----------------------------------------------------------------------------------"
           echo "|           Installation Java failed!Please check the cause of failure!           |"
           echo "-----------------------------------------------------------------------------------"
exit 1
}
yum localinstall -C -y --disablerepo=* $Dir_name/mariadb/*.rpm
[ $? -ne 0 ]&&{
clear
           echo "-----------------------------------------------------------------------------------"
           echo "|           Installation Mariadb failed!Please check the cause of failure!           |"
           echo "-----------------------------------------------------------------------------------"
exit 1
}
cd $Dir_name/mtnj/
tar -zxvf apache-tomcat* -C /usr/local/src/
tar -zxvf apache-maven* -C /usr/local/src/
tar -xvf node* -C /usr/local/src/
cd /usr/local/src
mv apache-tomcat* tomcat
mv apache-maven* maven
mv node* nodejs
clear
           echo "------------------------------------"
           echo "|         Install Done!!!          |"
           echo "------------------------------------"
tip;
base_environment;
init_variable;
init_tomcat;
init_mariadb;
finish;
echo -e "\e[4;32mJAVA Environment:\e[0m"
java -version
javac -version
echo -e "\e[4;32mMVN Environment:\e[0m"
mvn -v
echo -e "\e[4;32mNODE Environment:\e[0m"
node -v
ip="$(/sbin/ifconfig|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}')"

#判断tomcat是否运行成功？
#judge Tomcat status
#注意：java需要2-3分钟启动时间！脚本判断逻辑待更新！
echo -e "\e[4;34m******Tomcat Server detecting******\e[0m"
curl -o /dev/null -s -w "time_connect: %{time_connect}\ntime_starttransfer: %{time_starttransfer}\ntime_total: %{time_total}\n" "127.0.0.1" > /dev/null
if [ $? -eq '0' ]; then
    echo -e "\e[4;32mTomcat start success!\e[0m"
    echo -e "\e[4;32mYou can visit:http://$ip/ to verify!\e[0m"
    echo -e "\e[4;32mTip:Tomcat web root:/usr/local/src/tomcat/webapps/ROOT/\e[0m"
    exit 1
else
    echo -e "\e[4;31mTomcat failed to start!Please debug!\e[0m"
fi
}
;;
4){
exit 1
}
;;
5){
echo "Installing lamp...Please waiting!"
yum localinstall -C -y --disablerepo=* $Dir_name/base/*.rpm $Dir_name/mysql5.7.24/*.rpm $Dir_name/httpd/*.rpm $Dir_name/php/*.rpm
[ $? -ne 0 ]&&{
clear
           echo "-----------------------------------------------------------------------------------"
           echo "|         Installation package failed!Please check the cause of failure!          |"
           echo "-----------------------------------------------------------------------------------"
exit 1
}
clear
           echo "------------------------------------"
           echo "|         Install Done!!!          |"
           echo "------------------------------------"
tip;
base_environment;
web_data=/var/www/html
tar -zxf $Dir_name/phpMyAdmin-4.8.1-all-languages.tar.gz -C $web_data
mv $web_data/phpMyAdmin-4.8.1-all-languages $web_data/phpmyadmin
init_mysql5_7_24;
finish;
init_httpd;
ip="$(/sbin/ifconfig|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}')"
echo -e "\e[4;32mYou can visit:http://$ip/phpmyadmin/index.php to manage your database!\e[0m"
exit 1
}
;;
6){
echo "Installing lnmp...Please waiting!"
yum localinstall -C -y --disablerepo=* $Dir_name/base/*.rpm $Dir_name/mysql5.7.24/*.rpm $Dir_name/nginx/*.rpm $Dir_name/httpd/*.rpm $Dir_name/php/*.rpm
[ $? -ne 0 ]&&{
clear
           echo "-----------------------------------------------------------------------------------"
           echo "|         Installation package failed!Please check the cause of failure!          |"
           echo "-----------------------------------------------------------------------------------"
exit 1
}
clear
           echo "------------------------------------"
           echo "|         Install Done!!!          |"
           echo "------------------------------------"
tip;
base_environment;
web_data=/usr/share/nginx/html
tar -zxf $Dir_name/phpMyAdmin-4.8.1-all-languages.tar.gz -C $web_data
mv $web_data/phpMyAdmin-4.8.1-all-languages $web_data/phpmyadmin
init_mysql5_7_24;
finish;
init_nginx;
ip="$(/sbin/ifconfig|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}')"
echo -e "\e[4;32mYou can visit:http://$ip/phpmyadmin/index.php to manage your database!\e[0m"
echo -e "\e[4;32mTip:Nginx web root:/usr/share/nginx/html/\e[0m"
exit 1
}
esac
