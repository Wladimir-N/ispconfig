#!/bin/bash
#
# metadata_begin
# recipe: ISPConfig
# tags: debian11
# revision: 1-qs
# description_ru: Установка ISPConfig
# description_en: Install ISPConfig
# metadata_end
#
exec > ISPConfig.log 2>&1
echo -e 'deb http://security.debian.org/debian-security bullseye-security main non-free contrib\ndeb http://deb.debian.org/debian bullseye-updates main non-free contrib\ndeb http://deb.debian.org/debian bullseye main non-free contrib\ndeb http://deb.debian.org/debian bullseye-backports-sloppy main non-free contrib\ndeb http://deb.debian.org/debian bullseye-backports main non-free contrib\ndeb http://deb.debian.org/debian bullseye-proposed-updates main non-free contrib' > /etc/apt/sources.list
echo -e 'Package: *\nPin: release a=bullseye-security\nPin-Priority: 500\n\nPackage: *\nPin: release a=bullseye-updates\nPin-Priority: 500\n\nPackage: *\nPin: release a=bullseye\nPin-Priority: 500\n\nPackage: *\nPin: release a=bullseye-backports-sloppy\nPin-Priority: 500\n\nPackage: *\nPin: release a=bullseye-backports\nPin-Priority: 500\n\nPackage: *\nPin: release a=bullseye-proposed-updates\nPin-Priority: 500' > /etc/apt/preferences
DEBIAN_FRONTEND=noninteractive apt update
DEBIAN_FRONTEND=noninteractive apt -y upgrade
DEBIAN_FRONTEND=noninteractive apt -y dist-upgrade
DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends debconf-utils
echo 'dash dash/sh boolean false' |debconf-set-selections
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash
DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends ntp postfix postfix-mysql postfix-doc mariadb-client mariadb-server getmail6 rkhunter dovecot-imapd dovecot-pop3d dovecot-mysql dovecot-sieve dovecot-lmtpd sudo amavisd-new spamassassin clamav clamav-daemon unzip bzip2 arj nomarch lzop cabextract p7zip p7zip-full unrar lrzip apt-listchanges libnet-ldap-perl libauthen-sasl-perl clamav-docs daemon libio-string-perl libio-socket-ssl-perl libnet-ident-perl zip libnet-dns-perl libdbd-mysql-perl postgrey nginx-light php7.4-fpm php7.4 php7.4-gd php7.4-mysql php7.4-imap php7.4-cgi php-pear mcrypt imagemagick libruby php7.4-curl php7.4-intl php7.4-pspell php7.4-sqlite3 php7.4-tidy php7.4-xmlrpc php7.4-xsl memcached php-memcache php-imagick php-php-gettext php7.4-zip php7.4-soap php-apcu fcgiwrap letsencrypt pure-ftpd-common pure-ftpd-mysql fail2ban wget patch pwgen
echo -e '[mysqld]\nsql_mode=\nsync_binlog=0\ntransaction-isolation=READ-COMMITTED\nquery_cache_type=ON\ninnodb_flush_log_at_trx_commit=0\ninnodb_flush_method=O_DIRECT\ninnodb_buffer_pool_instances=1\ninnodb_strict_mode=OFF\nlow-priority-updates\nslow_query_log\nlong_query_time=29.99\nslow_query_log_file=/var/log/mysql/mariadb-slow.log' > /etc/mysql/mariadb.conf.d/51-server.cnf
systemctl restart mariadb
#DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends awstats geoip-database libtimedate-perl libclass-dbi-mysql-perl
#rm /etc/cron.d/awstats
#DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends jailkit
echo -e '\#!/bin/bash\n/usr/sbin/nginx -t && /usr/sbin/nginx -s reload' > /usr/local/bin/reload.sh
chmod +x /usr/local/bin/reload.sh
echo '33 16 */29 * * /usr/local/bin/reload.sh' | crontab
sed -i 's/#submission inet n       -       y       -       -       smtpd/submission inet n - y - - smtpd/' /etc/postfix/master.cf
sed -i 's/#  -o syslog_name=postfix\/submission/ -o syslog_name=postfix\/submission/' /etc/postfix/master.cf
sed -i 's/#  -o smtpd_tls_security_level=encrypt/ -o smtpd_tls_security_level=encrypt/' /etc/postfix/master.cf
sed -i 's/#  -o smtpd_sasl_auth_enable=yes/ -o smtpd_sasl_auth_enable=yes/' /etc/postfix/master.cf
sed -i 's/#  -o smtpd_client_restrictions=$mua_client_restrictions/ -o smtpd_client_restrictions=permit_sasl_authenticated,reject/' /etc/postfix/master.cf
sed -i 's/#smtps     inet  n       -       y       -       -       smtpd/smtps inet n - y - - smtpd/' /etc/postfix/master.cf
sed -i 's/#  -o syslog_name=postfix\/smtps/ -o syslog_name=postfix\/smtps/' /etc/postfix/master.cf
sed -i 's/#  -o smtpd_tls_wrappermode=yes/ -o smtpd_tls_wrappermode=yes/' /etc/postfix/master.cf
sed -i 's/#  -o smtpd_sasl_auth_enable=yes/ -o smtpd_sasl_auth_enable=yes/' /etc/postfix/master.cf
sed -i 's/#  -o smtpd_client_restrictions=$mua_client_restrictions/ -o smtpd_client_restrictions=permit_sasl_authenticated,reject/' /etc/postfix/master.cf
echo 'smtputf8_enable=no' >> /etc/postfix/main.cf
systemctl restart postfix
systemctl stop spamassassin
systemctl disable spamassassin
sed -i 's/VIRTUALCHROOT=false/VIRTUALCHROOT=true/' /etc/default/pure-ftpd-common
echo 1 > /etc/pure-ftpd/conf/TLS
mkdir -p /etc/ssl/private/
openssl req -x509 -nodes -days 7300 -newkey rsa:2048 -keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem  -subj "/C=RU/ST=Moscow/L=Moscow/O=/OU=/CN=$(hostname -f)/emailAddress=root@$(hostname -f)"
chmod 600 /etc/ssl/private/pure-ftpd.pem
systemctl restart pure-ftpd-mysql
echo -e '[pure-ftpd]\nenabled = true\nport = ftp\nfilter = pure-ftpd\nlogpath = /var/log/syslog\nmaxretry = 3\n\n[dovecot]\nenabled = true\nfilter = dovecot\nlogpath = /var/log/mail.log\nmaxretry = 5\n\n[postfix-sasl]\nenabled = true\nport = smtp\nfilter = postfix[mode=auth]\nlogpath = /var/log/mail.log\nmaxretry = 3' > /etc/fail2ban/jail.local
systemctl restart fail2ban
cd /tmp
wget http://www.ispconfig.org/downloads/ISPConfig-3-stable.tar.gz
tar xfz ISPConfig-3-stable.tar.gz
cd ispconfig3_install/install/
passwd_isp=$(pwgen 15 1)
passwd_db=$(pwgen 15 1)
echo -e "[install]\nlanguage=en\ninstall_mode=standard\nhostname=$(hostname -f)\nmysql_hostname=localhost\nmysql_port=3306\nmysql_root_user=root\nmysql_root_password=''\nmysql_database=dbispconfig\nmysql_charset=utf8\nhttp_server=nginx\nispconfig_port=81\nispconfig_use_ssl=n\nispconfig_admin_password=$passwd_isp\n\n[ssl_cert]\nssl_cert_country=RU\nssl_cert_state=Moscow\nssl_cert_locality=Moscow\nssl_cert_organisation=\nssl_cert_organisation_unit=\nssl_cert_common_name=$(hostname -f)\nssl_cert_email=hostmaster@$(hostname -f)\n\n[expert]\nmysql_ispconfig_user=ispconfig\nmysql_ispconfig_password=$passwd_db\njoin_multiserver_setup=n\nmysql_master_hostname=localhost\nmysql_master_root_user=root\nmysql_master_root_password=''\nmysql_master_database=dbispconfig\nconfigure_mail=y\nconfigure_jailkit=y\nconfigure_ftp=y\nconfigure_dns=n\nconfigure_apache=n\nconfigure_web=y\nconfigure_nginx=y\nconfigure_firewall=y\ninstall_ispconfig_web_interface=y" > autoinstall.ini
php install.php --autoinstall=autoinstall.ini
echo "admin $passwd_isp" > ~/.ispconfig.ini
echo -e 'User-Agent: *\nDisallow: /' > /var/www/robots.txt
#sed -i 's/short_open_tag = Off/short_open_tag=On/' /etc/php/7.3/cli/php.ini
