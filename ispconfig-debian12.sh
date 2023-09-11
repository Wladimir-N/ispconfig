#!/bin/bash
#
# metadata_begin
# recipe: ISPConfig
# tags: debian12
# revision: 1-qs
# description_ru: Установка ISPConfig
# description_en: Install ISPConfig
# metadata_end
#
exec > ISPConfig.log 2>&1
echo -e 'deb http://security.debian.org bookworm-security main contrib non-free non-free-firmware\ndeb http://deb.debian.org/debian bookworm-updates main non-free contrib non-free-firmware\ndeb http://deb.debian.org/debian bookworm-proposed-updates main non-free contrib non-free-firmware\ndeb http://deb.debian.org/debian bookworm-backports-sloppy main non-free contrib non-free-firmware\ndeb http://deb.debian.org/debian bookworm-backports main non-free contrib non-free-firmware\ndeb http://deb.debian.org/debian bookworm main non-free contrib non-free-firmware' > /etc/apt/sources.list
echo -e 'Package: *\nPin: release a=bookworm-security\nPin-Priority: 500\n\nPackage: *\nPin: release a=bookworm-updates\nPin-Priority: 500\n\nPackage: *\nPin: release a=bookworm-proposed-updates\nPin-Priority: 500\n\nPackage: *\nPin: release a=bookworm-backports-sloppy\nPin-Priority: 500\n\nPackage: *\nPin: release a=bookworm-backports\nPin-Priority: 500\n\nPackage: *\nPin: release a=bookworm\nPin-Priority: 500' > /etc/apt/preferences
DEBIAN_FRONTEND=noninteractive apt update
DEBIAN_FRONTEND=noninteractive apt -y upgrade
DEBIAN_FRONTEND=noninteractive apt -y dist-upgrade
DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends ntp postfix-mysql postfix-doc mariadb-client mariadb-server getmail6 rkhunter binutils dovecot-imapd dovecot-pop3d dovecot-mysql dovecot-sieve dovecot-lmtpd sudo curl rsyslog gnupg2 lsb-release rspamd redis clamav clamav-daemon unzip arj nomarch lzop cabextract p7zip p7zip-full unrar lrzip libnet-ldap-perl libauthen-sasl-perl clamav-docs daemon libnet-ident-perl zip libdbd-mysql-perl postgrey php8.2 php8.2-fpm php8.2-common php8.2-gd php8.2-mysql php8.2-imap php8.2-cli php8.2-cgi php-pear mcrypt imagemagick libruby php8.2-curl php8.2-intl php8.2-pspell php8.2-sqlite3 php8.2-tidy php8.2-xmlrpc php8.2-xsl php-imagick php8.2-zip php8.2-mbstring php8.2-soap php8.2-opcache php-apcu php8.2-mcrypt pure-ftpd-common pure-ftpd-mysql fail2ban iptables nginx-light fcgiwrap certbot patch pwgen
sed -i 's/#submission inet n       -       y       -       -       smtpd/submission inet n - y - - smtpd/' /etc/postfix/master.cf
sed -i 's/#  -o syslog_name=postfix\/submission/ -o syslog_name=postfix\/submission/' /etc/postfix/master.cf
sed -i 's/#  -o smtpd_tls_security_level=encrypt/ -o smtpd_tls_security_level=encrypt/' /etc/postfix/master.cf
sed -i 's/#  -o smtpd_sasl_auth_enable=yes/ -o smtpd_sasl_auth_enable=yes/' /etc/postfix/master.cf
sed -i 's/#submissions     inet  n       -       y       -       -       smtpd/submissions inet n - y - - smtpd/' /etc/postfix/master.cf
sed -i 's/#  -o smtpd_tls_wrappermode=yes/ -o smtpd_tls_wrappermode=yes/' /etc/postfix/master.cf
echo 'smtputf8_enable=no' >> /etc/postfix/main.cf
systemctl restart postfix
echo -e '[mysqld]\nsql_mode=\nsync_binlog=0\ntransaction-isolation=READ-COMMITTED\nquery_cache_type=ON\ninnodb_flush_log_at_trx_commit=0\ninnodb_flush_method=O_DIRECT\ninnodb_buffer_pool_instances=1\ninnodb_strict_mode=OFF\nlow-priority-updates\nslow_query_log\nlong_query_time=29.99\nslow_query_log_file=/var/log/mysql/mariadb-slow.log' > /etc/mysql/mariadb.conf.d/51-server.cnf
mkdir -p /var/log/mysql
chown mysql:mysql /var/log/mysql
systemctl restart mariadb
echo 'servers = "127.0.0.1";' > /etc/rspamd/local.d/redis.conf
echo "nrows = 2500;" > /etc/rspamd/local.d/history_redis.conf 
echo "compress = true;" >> /etc/rspamd/local.d/history_redis.conf
echo "subject_privacy = true;" >> /etc/rspamd/local.d/history_redis.conf
systemctl restart rspamd
sed -i 's/VIRTUALCHROOT=false/VIRTUALCHROOT=true/' /etc/default/pure-ftpd-common
echo 1 > /etc/pure-ftpd/conf/TLS
openssl req -x509 -nodes -days 7300 -newkey rsa:2048 -keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem  -subj "/C=RU/ST=Moscow/L=Moscow/O=/OU=/CN=$(hostname -f)/emailAddress=root@$(hostname -f)"
chmod 600 /etc/ssl/private/pure-ftpd.pem
systemctl restart pure-ftpd-mysql
echo -e '[pure-ftpd]\nenabled = true\nport = ftp\nfilter = pure-ftpd\nlogpath = /var/log/syslog\nmaxretry = 3\n\n[dovecot]\nenabled = true\nfilter = dovecot\nlogpath = /var/log/mail.log\nmaxretry = 5\n\n[postfix-sasl]\nenabled = true\nport = smtp\nfilter = postfix[mode=auth]\nlogpath = /var/log/mail.log\nmaxretry = 3' > /etc/fail2ban/jail.local
systemctl restart fail2ban
echo -e '\#!/bin/bash\n/usr/sbin/nginx -t && /usr/sbin/nginx -s reload' > /usr/local/bin/reload.sh
chmod +x /usr/local/bin/reload.sh
echo '37 16 */29 * * /usr/local/bin/reload.sh' | crontab

echo 'Далее ручная установка'
export passwd_root=$(pwgen 16 1)
#mysql_secure_installation
#Switch to unix_socket authentication [Y/n] <-- n
#Change the root password? [Y/n] <-- y
#New password: $passwd_root
#Re-enter new password: $passwd_root
#Remove anonymous users? [Y/n] <-- y
#Disallow root login remotely? [Y/n] <-- y
#Remove test database and access to it? [Y/n] <-- y
#Reload privilege tables now? [Y/n] <-- y

#sed -i "s/^user.*$/&\npassword = \"$passwd_root\"/"  /etc/mysql/debian.cnf

#cd /tmp
#wget http://www.ispconfig.org/downloads/ISPConfig-3-stable.tar.gz
#tar xfz ISPConfig-3-stable.tar.gz
#cd ispconfig3_install/install/
#export passwd_isp=$(pwgen 16 1)
#export passwd_db=$(pwgen 16 1)
#echo -e "[install]\nlanguage=en\ninstall_mode=standard\nhostname=$(hostname -f)\nmysql_hostname=localhost\nmysql_port=3306\nmysql_root_user=root\nmysql_root_password=$passwd_root\nmysql_database=dbispconfig\nmysql_charset=utf8\nhttp_server=nginx\nispconfig_port=81\nispconfig_use_ssl=n\nispconfig_admin_password=$passwd_isp\n\n[ssl_cert]\nssl_cert_country=RU\nssl_cert_state=Moscow\nssl_cert_locality=Moscow\nssl_cert_organisation=\nssl_cert_organisation_unit=\nssl_cert_common_name=$(hostname -f)\nssl_cert_email=hostmaster@$(hostname -f)\n\n[expert]\nmysql_ispconfig_user=ispconfig\nmysql_ispconfig_password=$passwd_db\njoin_multiserver_setup=n\nmysql_master_hostname=localhost\nmysql_master_root_user=root\nmysql_master_root_password=''\nmysql_master_database=dbispconfig\nconfigure_mail=y\nconfigure_jailkit=y\nconfigure_ftp=y\nconfigure_dns=n\nconfigure_apache=n\nconfigure_web=y\nconfigure_nginx=y\nconfigure_firewall=y\ninstall_ispconfig_web_interface=y" > autoinstall.ini
# php install.php --autoinstall=autoinstall.ini
#echo -e "admin $passwd_isp\n$passwd_root" > ~/.ispconfig.ini
#echo -e 'User-Agent: *\nDisallow: /' > /var/www/robots.txt
