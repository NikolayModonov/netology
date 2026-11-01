# Домашнее задание к занятию 4 «Работа с roles»

## Ссылки на репозитории

1. **Репозиторий с плейбуком:** [ansible-playbook](https://github.com/NikolayModonov/ansible-playbook)
2. **Репозиторий с ролью Vector:** [vector-role](https://github.com/NikolayModonov/vector-role)
3. **Репозиторий с ролью Lighthouse:** [lighthouse-role](https://github.com/NikolayModonov/lighthouse-role)

## Что сделано

- Playbook разбит на три роли: clickhouse, vector, lighthouse.
- Роли vector и lighthouse написаны с нуля, выложены в отдельные публичные репозитории.
- В роли вынесены переменные (defaults/vars), конфигурационные файлы помещены в templates.
- Написана документация к каждой роли (README.md).
- Ролям проставлены теги v1.0.0.
- В репозитории с плейбуком создан requirements.yml для скачивания ролей из GitHub.
- Плейбук site.yml использует роли и разворачивает ClickHouse, Vector и LightHouse. 
- Для обхода блокировки GitHub целевой нодой, скачивание LightHouse делегировано на контроллер (delegate_to: localhost).