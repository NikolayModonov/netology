# Домашнее задание к занятию «Средство визуализации Grafana»

## Задание 1. Развертывание связки Grafana + Prometheus

В Yandex Cloud развернута ВМ (Ubuntu 22.04). С помощью `docker-compose` поднят стек: `grafana`, `prometheus` и `node-exporter`.
В Grafana добавлен источник данных Prometheus (URL: `http://prometheus:9090`). Подключение успешно проверено.

![Datasource](img/19-03_01_datasource.png)

## Задание 2. Создание Dashboard

Создан дашборд `Netology Dashboard` с четырьмя панелями:
1. CPU Usage: `100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)`
2. Load Average: `node_load1`
3. RAM Available %: `node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100`
4. Disk Free Space: `node_filesystem_avail_bytes{mountpoint="/"}`

![Dashboard](img/19-03_02_dashboard.png)

## Задание 3. Настройка алертинга

В Grafana настроена точка контакта (Contact point) типа `Email` для отправки уведомлений. Проверка работы канала связи пройдена успешно.

![Alert](img/19-03_03_alert.png)

## Задание 4. Экспорт Dashboard

Дашборд экспортирован в формате JSON. Файл с конфигурацией приложен в репозитории по пути `src/dashboard.json`.