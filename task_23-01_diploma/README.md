# Дипломный практикум в Yandex.Cloud

Цель: подготовить облачную инфраструктуру, развернуть Kubernetes кластер,
установить систему мониторинга, настроить CI/CD для тестового приложения.

Этапы:

1. Облачная инфраструктура (Terraform)
2. Kubernetes кластер (Kubespray + Ansible)
3. Тестовое приложение (nginx + Docker)
4. Мониторинг и деплой приложения (kube-prometheus-stack)
5. CI/CD (GitHub Actions)

Репозитории проекта:

- diploma-tf - Terraform-инфраструктура
- diploma-ansible - Kubespray-конфиг и inventory
- diploma-app - тестовое приложение и Dockerfile
- diploma-k8s - манифесты и helm-чарты кластера

