# Настройка общего git репозитория в режиме многосайтовости

Настройка на случай если у вас есть необходимость держать **код сайтов в общем репозитории**.

1. После установки основного сайта и остальных. Переходим к настройке общего репозитория. Для этого переходим в домашний каталог SSH пользователя созданного через ISPConfig при развертывании первого сайта. (Обратите внимание если вы создавали в ISPConfig клиентов и/или еще сайта пути могут отличаться от примера. А так же будет отличаться логин SSH пользователя)
    ```bash
    cd /var/www/clients/client0/web1/private
    ```
2. Создаем каталог проекта обобщающего сайты. (например 'myproject') И переходим в него 
    ```bash
    mkdir myproject
    cd myproject
    ```
3. Создаем каталоги для каждого сайта проекта
    ```bash
    mkdir site1.ru
    mkdir site2.ru
    ```
4. Авторизуемся как root `su -` либо `sudo -i`. И в файле fstab добавляем строки задающие монтирование
    ```bush
    /var/www/clients/client0/web1/web /var/www/clients/client0/web1/private/myproject/site1.ru/ none bind,nofail 0,0
    /var/www/clients/client0/web2/web /var/www/clients/client0/web1/private/myproject/site2.ru/ none bind,nofail 0,0
    ```
    И перезагружаем сервер
    ```bush
    shutdown -r now
    ```
5. В каталоге /var/www/clients/client0/web1/private/myproject/ git или загружаем с другого источника
6. При необходимости клонируем на рабочий компьютер
    ```bush
    git clone ssh://defaultuser@site1.ru/var/www/clients/client0/web1/private/myproject
   ```


