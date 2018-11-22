# 使用帮助  
1、web_install.sh只是安装脚本，还需要下载软件包。  
2、该脚本仅支持离线安装、仅适用rhel7/centos7系统。  
3、Usage:sh web_install.sh  
4、md5sum web_install_v1.8.tar.gz   
634f32d90ea775975c380bbe80da01f9  web_install_v1.8.tar.gz  
5、软件包下载地址：https://drive.google.com/file/d/15dXLjogUHXveybOd4-_BuhhThqO8yD5Q/view?usp=sharing  

# 相关信息  
******************************************************  
Author       : Lifa  
Email        : 991179382@qq.com  
Usage: sh web_install.sh  
This script is only suitable for **rhel7/centos7** systems!  
lamp lnmp ltmj,Only one of them can be installed, otherwise it will go wrong!  
SOFTWARE VERSION:  
JAVA_VERSION: 1.8.0_171  
TOMCAT_VERSION: 9.0.10  
MAVEN_VERSION: 3.5.4  
NODEJS_VERSION: 10.5.0  
MARIADB_VERSION: 5.5.56  
APACHE_VERSION: 2.4.6  
NGINX_VERSION: 1.14.0  
PHP_VERSION: 7.0.30  
MYSQL_VERSION: 5.7.24  
******************************************************  
  
## History:  
**web_install.sh_v1.1**: Add lamp.  
  
**web_install.sh_v1.2**: .  
  
**web_install.sh_v1.3**: .  
  
**web_install.sh_v1.4**: If yum fail then exit 1.  
  
**web_install.sh_v1.5**: Add ltmj.  
  
**web_install.sh_v1.6**:   
Add lnmp.  
Reclassification of installation packages.  
Ignore URL case for Apache but not for Nginx.  
*Tip: 其实这里是不用安装mvn和nodejs的，因为这两个工具本身就是为开发环境提供辅助的，运行环境不必安装。  
另外如果应用是用spring boot写的，则运行环境也不需要安装tomcat，spring boot本身就自带了tomcat环境。*  
  
**web_install.sh_v1.7**: 凡是关于“cat >>”的配置都增加了判断逻辑：“原有文件是否有该配置”，防止添加了又添加。  
添加了“判断Tomcat运行状态”的脚本。  
  
**web_install.sh_v1.8**:   
Add MYSQL_VERSION :v5.7.24  

