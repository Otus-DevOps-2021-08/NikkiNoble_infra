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
# Задание Terraform-2
- Настройка хранения стейта файла в удаленном бекенде (remote backends) для окружений stage и prod, используя Yandex Object Storage в качестве бекенда (https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-state-storage)
(https://cloud.yandex.ru/docs/storage/operations/buckets/create)
    - Настройка провайдера

            terraform {
                required_providers {
                    yandex = {
                        source  = "yandex-cloud/yandex"
                        version = "0.61.0"
                    }
                }
            }

            provider "yandex" {
                token     = "<OAuth>"
                cloud_id  = "<идентификатор облака>"
                folder_id = "<идентификатор каталога>"
                zone      = "<зона доступности по умолчанию>"
            }
    - Настройка бэкенда

            terraform {
                backend "s3" {
                    endpoint   = "storage.yandexcloud.net"
                    bucket     = "<имя бакета>"
                    region     = "us-east-1"
                    key        = "<путь к файлу состояния в бакете>/<имя файла      состояния>.tfstate"
                    access_key = "<идентификатор статического ключа>"
                    secret_key = "<секретный ключ>"

                    skip_region_validation      = true
                    skip_credentials_validation = true
                }
            }
- Необходимые provisioner добавлены в модули для деплоя и работы приложения.
(https://www.terraform.io/docs/language/functions/templatefile.html)

            provisioner "file" {
                content     = templatefile("${path.module}/files/puma.service.tmpl", { database_url = var.database_url })
                destination = "/tmp/puma.service"
            }

            provisioner "remote-exec" {
                script = "./${path.module}/files/deploy.sh"
            }
# Задание Ansible-1
Управление хостом при помощи Ansible

    $ ansible appserver -i ./inventory -m ping
    $ ansible app -m ping

ansible.cfg

    [defaults]
    inventory = ./inventory
    remote_user = ubuntu
    private_key_file = ~/.ssh/appuser
    host_key_checking = False
    retry_files_enabled = False

Inventory file с группами хостов

    [app]
    appserver ansible_host=178.154.202.44

    [db]
    dbserver ansible_host=62.84.119.51

YAML inventory

    app:
        hosts:
            appserver:
                ansible_host: 178.154.202.44

Выполнение команд:

    $ ansible app -m command -a 'ruby -v'
    $ ansible app -m shell -a 'ruby -v; bundler -v'
    $ ansible db -m command -a 'systemctl status mongod'
    $ ansible db -m systemd -a name=mongod
    $ ansible db -m service -a name=mongod
    $ ansible app -m git -a 'repo=https://github.com/express42/reddit.git dest=/home/appuser/reddit'

Playbook

    ---
    - name: Clone
    hosts: app
    tasks:
        - name: Clone repo
        git:
            repo: https://github.com/express42/reddit.git
            dest: /home/appuser/reddit

    ansible-playbook clone.yml

Удаляет ранее скаченные материалы и директорию reddit:

    ansible app -m command -a 'rm -rf ~/reddit'
