# NikkiNoble_infra
NikkiNoble Infra repository

# Задание Cloud bastion

bastion_IP = 62.84.118.87
someinternalhost_IP = 10.128.0.26

### Вариант решения для подключения из консоли при помощи команды вида `ssh someinternalhost` из локальной консоли рабочего устройства:

* Используя SSH Config File

`$ touch ~/.ssh/config`

    Host bastion
        HostName 62.84.118.87
        User appuser
        IdentityFile ~/.ssh/appuser

    Host someinternalhost
        HostName 10.128.0.26
        User appuser
        IdentityFile ~/.ssh/appuser
        ProxyJump bastion

### Cпособ подключения к `someinternalhost` в одну команду из рабочего устройства:

* с помощью -J command line flag

        ssh -i ~/.ssh/appuser -A -J appuser@62.84.118.87 appuser@10.128.0.26

### Валидный сертификат:
* https://62.84.118.87.sslip.io

_________________________

# Задание Cloud TestApp

testapp_IP = 62.84.114.235
testapp_port = 9292

### Startup Script
`sudo bash startup.sh` - после применения данной команды CLI получается инстанс с уже запущенным приложением.

    yc compute instance create \
     --name reddit-app \
     --hostname reddit-app \
     --memory=4 \
     --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=10GB \
     --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
     --metadata serial-port-enable=1 \
     --metadata-from-file user-data=metadata.yml

# Задание Packer
- Создан шаблон immutable.json.
- Для запуска приложения при старте инстанса использован systemd unit.

### Запуск сборки образа
    packer build -var-file=variables.json immutable.json

### Создание ВМ с помощью Yandex.Cloud CLI
    sudo bash create-reddit-vm.sh

### Проверка образа
     http://<внешний IP машины>:9292

# Задание Terraform-1

- В файле `main.tf` определен провайдер, добавлен ресурс для создания инстанса VM в YC.
- Создан отдельный файл `outputs.tf` для выходных переменных с основной конфигурацией ресурсов.
- Внутрь ресурса, содержащего описание VM, вставлены секции провижинеров `file`, `remote-exec` и определены параметры подключения к VM.
- Команды создания ресурсов:
    - `terraform plan`
    - `terraform apply`
- Команда удаления ресурсов:
    - `terraform destroy`
- Входные переменные определены в конфигурационных файлах `variables.tf` и `terraform.tfvars`
- Создан файл `lb.tf`, в нем описано создание HTTP балансировщика, направляющего трафик на развернутое приложение на инстансе reddit-app (https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/lb_target_group) (https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/lb_network_load_balancer)
- Так как подход с созданием дополнительного инстанса копированием
кода нерационален, использован подход с заданием количества инстансов через параметр ресурса `count` (https://www.terraform.io/docs/language/meta-arguments/count.html)

        ${count.index}
- Чтобы динамически включать приложения в `target group` использован `dynamic` block (https://www.terraform.io/docs/language/expressions/dynamic-blocks.html)

        dynamic target {
            for_each = yandex_compute_instance.app.*.network_interface.0.ip_address
            content {
                subnet_id = var.subnet_id
                address   = target.value
            }
        }
