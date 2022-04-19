#!/bin/bash
exit_func () {
 whiptail --title "Завершение программы установки" --msgbox "Благодарю за использование программы" 10 60
 clear
 echo "Благодарю за использование программы."
}
DISTROS=$(whiptail --title "Меню программы установки" --checklist \
"Вас приветствует скрипт полуатоматической установки программ и обновлений. Установите звёздочки на против желаемых пунктов." 23 77 16 \
"1" "Roundcube" OFF \
"2" "Дополнительные версии php" OFF \
"3" "Tiny File Manager" OFF 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
	for OPTION in ${DISTROS//'"'/}
	do
	if [ $OPTION = 1 ]; then
		PHP=$(whiptail --title "Меню программы установки" --menu \
     "Выберите версию php" 23 77 16 \
     "8.1" " " \
     "8.0" " " \
     "7.4" " " \
     "7.3" " " \
     "7.2" " " \
     "7.1" " " \
     "7.0" " " \
     "5.6" " " 3>&1 1>&2 2>&3)
		exitstatus=$?
		if [ $exitstatus = 0 ]; then
			ls /etc/php/$PHP/fpm/pool.d/
			exitstatus=$?
			if [ $exitstatus != 0 ]; then
				whiptail --title "Выбранная версия php не установлена" --msgbox "Установите нужную версию php из главного меню" 10 60
				$0
				exit
			fi
			DEBIAN_FRONTEND=noninteractive apt update
			DEBIAN_FRONTEND=noninteractive apt -y upgrade
			DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends roundcube roundcube-core roundcube-mysql roundcube-plugins
			sed -i "s/config\['default_host'\] = '';/config\['default_host'\] = 'localhost';/" /etc/roundcube/config.inc.php
			domain=$(whiptail --title  "Выбор доменного имени" --inputbox  "Введите домен по которому должен открываться интерфейс" 10 60 mail.domains.ru 3>&1 1>&2 2>&3)
			echo -e "server {\n listen 80;\n server_name ${domain};\n root /usr/share/roundcube/;\n index index.php index.html index.htm;\n client_max_body_size 100M;\n location ~* ^.+.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt)$ { access_log off; }\n location ~ /\. { internal; }\n location ~ ^.+\.php$ {\n  try_files \$uri =404;\n  fastcgi_param   QUERY_STRING     \$query_string;\n  fastcgi_param   REQUEST_METHOD   \$request_method;\n  fastcgi_param   CONTENT_TYPE     \$content_type;\n  fastcgi_param   CONTENT_LENGTH   \$content_length;\n  fastcgi_param   SCRIPT_FILENAME  \$request_filename;\n  fastcgi_param   SCRIPT_NAME      \$fastcgi_script_name;\n  fastcgi_param   REQUEST_URI      \$request_uri;\n  fastcgi_param   DOCUMENT_URI     \$document_uri;\n  fastcgi_param   DOCUMENT_ROOT    \$document_root;\n  fastcgi_param   SERVER_PROTOCOL  \$server_protocol;\n  fastcgi_param   GATEWAY_INTERFACE       CGI/1.1;\n  fastcgi_param   SERVER_SOFTWARE  nginx/\$nginx_version;\n  fastcgi_param   REMOTE_ADDR      \$remote_addr;\n  fastcgi_param   REMOTE_PORT      \$remote_port;\n  fastcgi_param   SERVER_ADDR      \$server_addr;\n  fastcgi_param   SERVER_PORT      \$server_port;\n  fastcgi_param   SERVER_NAME      \$server_name;\n  fastcgi_param   HTTPS     \$https;\n  fastcgi_param   REDIRECT_STATUS  200;\n  fastcgi_pass unix:/var/lib/php7.3-fpm/ispconfig$PHP.sock;\n  fastcgi_index index.php;\n  fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;\n  fastcgi_buffer_size 128k;\n  fastcgi_buffers 256 4k;\n  fastcgi_busy_buffers_size 256k;\n  fastcgi_temp_file_write_size 256k;\n  fastcgi_param PHP_ADMIN_VALUE \"mbstring.func_overload=0\";\n }\n location ^~ /.well-known/acme-challenge/ {\n  access_log off;\n  log_not_found off;\n  root /usr/local/ispconfig/interface/acme/;\n  autoindex off;\n  index index.html;\n  try_files \$uri \$uri/ =404;\n }\n}" > /etc/nginx/sites-available/$domain
			ln -s /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/$domain
			if ! [ -f /etc/php/$PHP/fpm/pool.d/ispconfig.conf ]
			then
				cp $(ls /etc/php/*/fpm/pool.d/ispconfig.conf) /etc/php/$PHP/fpm/pool.d/
				sed -i "s/listen = \/var\/lib\/php7\..-fpm\/ispconfig.sock/listen = \/var\/lib\/php7.3-fpm\/ispconfig$PHP.sock/" /etc/php/$PHP/fpm/pool.d/ispconfig.conf
			fi
			systemctl reload php$PHP-fpm
			nginx -t && nginx -s reload
			chown -R ispconfig:ispconfig /etc/roundcube
		else
			exit_func
		fi
	elif [ $OPTION = 2 ]; then
		PHP=$(whiptail --title "Меню программы установки" --menu \
     "Выберите версию php" 23 77 16 \
     "8.1" " " \
     "8.0" " " \
     "7.4" " " \
     "7.3" " " \
     "7.2" " " \
     "7.1" " " \
     "7.0" " " \
     "5.6" " " 3>&1 1>&2 2>&3)
    if [ $exitstatus = 0 ]; then
			DEBIAN_FRONTEND=noninteractive apt update
			DEBIAN_FRONTEND=noninteractive apt -y upgrade
			DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends gnupg
			echo "deb https://packages.sury.org/php $(grep VERSION_CODENAME /etc/os-release | cut -d '=' -f 2) main" > /etc/apt/sources.list.d/php.list
			wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
			DEBIAN_FRONTEND=noninteractive apt update
			if [ $PHP = 8.0 ];then
				DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends php$PHP php$PHP-common php$PHP-gd php$PHP-mysql php$PHP-imap php$PHP-cli php$PHP-cgi php$PHP-curl php$PHP-intl php$PHP-pspell php$PHP-sqlite3 php$PHP-tidy php$PHP-xsl php$PHP-common php$PHP-zip php$PHP-mbstring php$PHP-soap php$PHP-fpm php$PHP-opcache php$PHP-fpm
			else
				DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends php$PHP php$PHP-common php$PHP-gd php$PHP-mysql php$PHP-imap php$PHP-cli php$PHP-cgi php$PHP-curl php$PHP-intl php$PHP-pspell php$PHP-sqlite3 php$PHP-tidy php$PHP-xmlrpc php$PHP-xsl php$PHP-memcache php$PHP-imagick php$PHP-gettext php$PHP-zip php$PHP-mbstring php$PHP-soap php$PHP-fpm php$PHP-opcache php$PHP-apcu php$PHP-fpm
			fi
			rm /etc/apt/sources.list.d/php.list
			DEBIAN_FRONTEND=noninteractive apt update
			echo -e "https://t.me/Manualst/3\nИмя PHP $PHP\nПуть к бинарнику PHP FastCGI /usr/bin/php-cgi$PHP\nПуть к каталогу php.ini FastCGI /etc/php/$PHP/cgi/php.ini\nПуть к скрипту нициализации PHP-FPM php$PHP-fpm\nПуть к каталогу php.ini PHP-FPM /etc/php/$PHP/fpm/php.ini\nПуть до каталога пула PHP-FPM /etc/php/$PHP/fpm/pool.d/"
		else
			exit_func
		fi
	elif [ $OPTION = 3 ]; then
		if [ ! -e /usr/bin/git ]; then
			DEBIAN_FRONTEND=noninteractive apt update
			DEBIAN_FRONTEND=noninteractive apt -y upgrade
			DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends git
		fi
		cd /usr/share/php
		git clone https://github.com/prasathmani/tinyfilemanager.git
		dir=$(whiptail --title  "Выбор названия директории" --inputbox  "Введите название директории" 10 60 tinyfilemanager 3>&1 1>&2 2>&3)
		if [ "$dir" != "tinyfilemanager" ];then
			mv tinyfilemanager $dir
		fi
		cd $dir
		sed -i 's/{"lang":"en","error_reporting":false,"show_hidden":false,"hide_Cols":false,"calc_folder":false}/{"lang":"ru","error_reporting":false,"show_hidden":false,"hide_Cols":false,"calc_folder":false}/' tinyfilemanager.php
		sed -i "s/    'admin' => '/\/\/    'admin' => '/" tinyfilemanager.php
		sed -i "s/    'user' => '/\/\/    'user' => '/" tinyfilemanager.php
		USER=$(whiptail --title  "Выбор логина" --inputbox  "Введите логин" 10 60 admin 3>&1 1>&2 2>&3)
		PASSWORD=$(whiptail --title  "Выбор пароля" --inputbox  "Введите пароль в зашифрованном виде, для шифрования пароля перейдите по https://tinyfilemanager.github.io/docs/pwd.html предустановленный пароль соответствует admin@123" 10 60 '$2y$10$/K.hjNr84lLNDt8fTXjoI.DBp6PpeyoJ.mGwrrLuCZfAwfSAGqhOW' 3>&1 1>&2 2>&3)
		sed -i "s/auth_users = array(/auth_users = array(\n \"$USER\" => \"$PASSWORD\"/" tinyfilemanager.php
		sed -i "s/default_timezone = 'Etc\/UTC'; /default_timezone = 'Europe\/Moscow'; /" tinyfilemanager.php
		sed -i "s/root_path = \$_SERVER\['DOCUMENT_ROOT'\];/root_path = \$_SERVER\['HOME'\];/" tinyfilemanager.php
		echo "Скопируйте конфигурацию которую нужно будет добавлять:"
		echo -e "location /$dir/ {\n root /usr/share/php/;\n index tinyfilemanager.php;\n location ~ [^/]+\\.php$ {\n  try_files \$uri =404;\n  include /etc/nginx/fastcgi_params;\n  {FASTCGIPASS}\n  fastcgi_index tinyfilemanager.php;\n  fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;\n  fastcgi_intercept_errors on;\n }\n}"
	fi
 done
else
	exit_func
fi
