# Домашнее задание к занятию "Кеширование Redis/memcached" - Модонов Николай

### Задание 1. Кеширование

Проблемы, которые может решить кеширование:
- Высокая нагрузка на базу данных (снижение количества тяжелых read-запросов).
- Медленный отклик приложения при частом запросе одних и тех же данных.
- Долгое выполнение ресурсоемких вычислений (кэширование готовых результатов).
- Избыточное потребление сетевого трафика (отдача статики из локального кэша).

### Задание 2. Memcached

1. Скриншот статуса сервиса memcached
![Memcached Status](https://github.com/NikolayModonov/netology/blob/main/task_11-02/img/11-02_02_memcached-status.jpg)
2. Проверка статуса
```bash
systemctl status memcached --no-pager | cat
```

### Задание 3. Удаление по TTL в Memcached

1. Скриншот записи и удаления ключей по TTL
![Memcached TTL](https://github.com/NikolayModonov/netology/blob/main/task_11-02/img/11-02_03_memcached-ttl.jpg)
2. Команды для тестирования TTL
```bash
telnet localhost 11211
set key1 0 5 6
value1
get key1
```

### Задание 4. Запись данных в Redis

1. Скриншот записи и чтения ключей в Redis
![Redis Test](https://github.com/NikolayModonov/netology/blob/main/task_11-02/img/11-02_04_redis-test.jpg)
2. Команды Redis
```bash
redis-cli SET mykey "Hello"
redis-cli SET anotherkey "World"
redis-cli KEYS '*'
redis-cli GET mykey
redis-cli GET anotherkey
```

### Задание 5. Работа с числами

1. Скриншот увеличения значения ключа
![Redis Int](https://github.com/NikolayModonov/netology/blob/main/task_11-02/img/11-02_05_redis-int.jpg)
2. Команды Redis для работы с числами
```bash
redis-cli SET key5 5
redis-cli INCRBY key5 5
redis-cli GET key5
```