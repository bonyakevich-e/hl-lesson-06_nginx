### OTUS High Load Lesson #06 | Subject: Nginx - балансировка и отказоустойчивость
---------------------

#### ЦЕЛЬ: Научиться использовать Nginx в качестве балансировщика

---------------------
#### НЕОБХОДИМО: 
- 1 виртуальная машина - Nginx в качестве балансировщика
- n виртуальных машин - бэкенд на выбор студента (любое приложение из гитхаба - uwsgi/unicorn/php-fpm/java или свой самописный бэкенд) + nginx со статикой

В работе должны применяться:
- terraform
- ansible
- nginx

---------------------
#### КРИТЕРИИ ОЦЕНКИ:
Статус "Принято" ставится при выполнении вышеперечисленных требований

---------------------
#### ВЫПОЛНЕНИЕ:

Стенд состоит из двух виртуальных машинын, которые создаются с помощью Terraform в яндекс облаке. На первой машине установлен Nginx, который выполняет баллансировку на бэкенды и отдаёт статику. На второй машине поднятно четыре docker-контейнера, которые выступают в роли бэкендов.

![Untitled Diagram (1)](https://github.com/user-attachments/assets/b29ee2df-8a51-446c-9a06-09d762fbe7f5)

Для развёртывание стенда: 
1. скачиваем репозиторий
2. выполняем команды:
```
$ terraform init
$ terraform apply
```
Terraform развернёт две виртуальные машины в yandex cloud и запустить Ansible плейбук. Ansible поднимет 4ре docker-контейнера на виртуальной машине `backend01`, и настроит балансировку с помощью nginx на виртуальной машине `nginx`.

Для проверки нужно несколько раз перейти по внешнему адресу виртуальной машины `nginx`. Цвет фона страницы и текст должен меняться, чтобы будет свидетельствовать о корректно работающей баллансировке между бэкендами. 
Статика отдается по адресу http://nginx.external.ip/images/1.jpg, http://nginx.external.ip/images/2.jpg, http://nginx.external.ip/images/3.jpg. Статика лежит на самом балансировщике. Это сделано только для тестирования, по правильному она конечно должна быть на бэкенде. 
