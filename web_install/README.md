# ******************************************************
# Author       : Lifa
# Last modified: 2018-07-20 13:51
# Email        : 991179382@qq.com
# ******************************************************

# JAVA_VERSION: 1.8.0_171
# TOMCAT_VERSION: 9.0.10
# MAVEN_VERSION: 3.5.4
# NODEJS_VERSION: 10.5.0
# MARIADB_VERSION: 5.5.56
# APACHE_VERSION: 2.4.6
# NGINX_VERSION: 1.14.0
# PHP_VERSION: 7.0.30
# MYSQL_VERSION: 5.7.24

# 1.[[[Usage]]]: sh web_install.sh , Wait and choose!

# 2.[[[Warning]]]: lamp+phpmyadmin lnmp+phpmyadmin ltmj+maven+node
# Only one of them can be installed, otherwise it will go wrong!

# 3.[[[History]]]:
# web_install.sh_v1.1: Add lamp.

# web_install.sh_v1.2: .

# web_install.sh_v1.3: .

# web_install.sh_v1.4: If yum fail then exit 1.

# web_install.sh_v1.5: Add ltmj.

# web_install.sh_v1.6: 
# Add lnmp.
# Reclassification of installation packages.
# Ignore URL case for Apache but not for Nginx.
# Tip: 其实这里是不用安装mvn和nodejs的，因为这两个工具本身就是为开发环境提供辅助的，运行环境不必安装。
# 另外如果应用是用spring boot写的，则运行环境也不需要安装tomcat，spring boot本身就自带了tomcat环境。

# web_install.sh_v1.7: 凡是关于“cat >>”的配置都增加了判断逻辑：“原有文件是否有该配置”，防止添加了又添加。
# 添加了“判断Tomcat运行状态”的脚本。

# web_install.sh_v1.8: 
# Add MYSQL_VERSION :v5.7.24



