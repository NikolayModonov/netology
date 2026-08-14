# Домашнее задание к занятию "Кластеризация и балансировка нагрузки" - Модонов Николай

### Задание 1
Запустите два simple python сервера на своей виртуальной машине на разных портах. Установите и настройте HAProxy. Настройте балансировку Round-robin на 4 уровне.

Требования к результату
1. На проверку направьте конфигурационный файл haproxy, скриншоты, где видно перенаправление запросов на разные серверы при обращении к HAProxy.

Решение:
1. Скриншот перенаправления запросов на разные серверы (Round-robin L4)
![Перенаправление запросов Round-robin L4](https://github.com/NikolayModonov/netology/blob/main/task_10-01/img/10-01_01_round-robin-l4.jpg)
2. Конфигурационный файл HAProxy
[haproxy.cfg.01](https://github.com/NikolayModonov/netology/blob/main/task_10-01/src/haproxy.cfg.01)
3. Команды для запуска серверов и проверки балансировки

```bash
# Запуск python серверов
systemd-run --unit=python_server1 python3 -m http.server 8001 --directory /srv/server1
systemd-run --unit=python_server2 python3 -m http.server 8002 --directory /srv/server2

# Проверка балансировки
curl http://127.0.0.1
curl http://127.0.0.1
curl http://127.0.0.1
curl http://127.0.0.1
```

---

### Задание 2
Запустите три simple python сервера на своей виртуальной машине на разных портах. Настройте балансировку Weighted Round Robin на 7 уровне, чтобы первый сервер имел вес 2, второй - 3, а третий - 4. HAproxy должен балансировать только тот http-трафик, который адресован домену example.local.

Требования к результату
1. На проверку направьте конфигурационный файл haproxy, скриншоты, где видно перенаправление запросов на разные серверы при обращении к HAProxy c использованием домена example.local и без него.

Решение:
1. Скриншот перенаправления запросов с использованием домена example.local (Weighted RR L7)
![Weighted RR L7 example.local](https://github.com/NikolayModonov/netology/blob/main/task_10-01/img/10-01_02_weighted-rr-l7.jpg)
2. Скриншот ответа при обращении без домена example.local (403 Forbidden)
![403 Forbidden без example.local](https://github.com/NikolayModonov/netology/blob/main/task_10-01/img/10-01_03_access-control.jpg)
3. Конфигурационный файл HAProxy
[haproxy.cfg](https://github.com/NikolayModonov/netology/blob/main/task_10-01/src/haproxy.cfg.02)
4. Файл Vagrant с автоматическим развертыванием инфраструктуры и прогоном тестов
[Vagrantfile](https://github.com/NikolayModonov/netology/blob/main/task_10-01/src/Vagrantfile)
5. Команды для тестирования

```bash
# Тест балансировки с доменом
Test command: curl -s -H 'Host: example.local' http://127.0.0.1

# Тест без домена
curl -s -i http://127.0.0.1
```

---