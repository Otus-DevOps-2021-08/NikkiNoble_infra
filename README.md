# NikkiNoble_infra
NikkiNoble Infra repository

# Задание Cloud bastion

bastion_IP = 62.84.112.127
someinternalhost_IP = 10.128.0.30

### Вариант решения для подключения из консоли при помощи команды вида `ssh someinternalhost` из локальной консоли рабочего устройства:

* Используя SSH Config File

`$ touch ~/.ssh/config`

    Host bastion
        HostName 62.84.112.127
        User appuser
        IdentityFile ~/.ssh/appuser

    Host someinternalhost
        HostName 10.128.0.30
        User appuser
        IdentityFile ~/.ssh/appuser
        ProxyJump bastion

### Cпособ подключения к `someinternalhost` в одну команду из рабочего устройства:

* с помощью -J command line flag

        ssh -i ~/.ssh/appuser -A -J appuser@62.84.112.127 appuser@10.128.0.30

### Валидный сертификат:
* https://62.84.112.127.sslip.io
