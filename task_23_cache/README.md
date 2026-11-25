# Диплом Netology DevOps - Yandex Cloud (task_23)

Этот файл - единый контекст проекта для нейросети-ассистента: если тебя
(нейросеть) привели по ссылке на этот файл - читай его целиком, он содержит
план выполнения всего диплома, зафиксированные решения, места хранения
секретов и текущий статус. После чтения сразу приступай к работе над
текущим этапом, ничего дополнительно объяснять не нужно.

СТРОГО ЗАПРЕЩЕНО хранить здесь или в этом репозитории любые секреты
(ключи, пароли, токены, kubeconfig). Только ссылки на места их хранения.

---

## 1. Общая информация (ко всем этапам)

- Задание диплома (критерии - ЧТО делать):
  https://github.com/netology-code/devops-diplom-yandexcloud
- Требование задания: все файлы, скриншоты, README - в одном git-репозитории.
- Облако: Yandex Cloud
- Kubernetes: самостоятельный, 3 ВМ, развёртывание Kubespray через Ansible
- CI/CD: GitHub Actions
- Мониторинг: kube-prometheus-stack (helm)
- Приложение: nginx + статическая страница
- Правила оформления этого файла (действуют на весь файл):
  - Любые горизонтальные линии (тире, дефисы, длинные тире и т.п.) пишутся
    только символом минуса "-". Символы "—", "–" и прочие палки запрещены.
  - Символ подчёркивания "_" разрешён.
  - Внутри текста файла запрещён символ обратной кавычки; тройная обратная
    кавычка записывается как +++

## 2. Репозитории (ко всем этапам)

- diploma-tf - Terraform: VPC, подсети, ВМ, backend state
- diploma-ansible - Kubespray, inventory
- diploma-app - nginx конфиг, Dockerfile, статика, CI/CD workflow
- diploma-k8s - helm-чарты и манифесты (monitoring, app, ingress)
- diploma-report - главный README отчёта со ссылками на репозитории выше
- Репозиторий с финальной версией диплома, который сдаётся: https://github.com/NikolayModonov/netology/tree/main/task_23-01_diploma
- Репозиторий наполняется по мере готовности каждого этапа.
- Этот файл (https://github.com/NikolayModonov/netology/tree/main/task_23_cache/README.md) - контекст проекта: техническая информация, план и текущий статус. Текущий этап смотреть в статусе соответствующего этапа, начинать работу только с него.
- Рабочие материалы (код, скриншоты, README этапов) ведутся в репозитории сдачи; этот файл - только контекст, их не дублирует.

## 3. Зафиксированные решения (ко всем этапам)

- ВМ: standard-v2, 2 CPU / 4 GB RAM, Ubuntu 22.04, 3 шт (ru-central1-a/b/d)
- K8s: 1 control-plane + 2 worker, CNI calico (Kubespray stacked)
- Backend TF state: S3-бакет ЯО + YDB (DynamoDB-совместимый) для блокировки
- Registry: НАЧИНАЕМ С DockerHub (публичный образ, imagePullSecret не нужен).
  ВНИМАНИЕ: задание требует приватный Yandex Container Registry. Если
  преподаватель придирётся - переключаемся на YCR на этапе 3.
- CI/CD-terraform (требование задания об автоприменении TF) закрывается
  GitHub Actions workflow в diploma-tf: plan на PR, apply при merge в main.
  Отдельный Atlantis не нужен.

## 4. Поток артефактов (ко всем этапам)

- TF outputs (IP ВМ, id подсетей) -> ansible inventory этапа 2
- kubeconfig этапа 2 -> GitHub Secrets -> этапы 4 и 5
- имя образа этапа 3 -> Deployment этапа 4 и workflow этапа 5
- SA JSON key этапа 1 -> GitHub Secrets -> CI/CD-terraform
- DockerHub/YCR creds -> GitHub Secrets -> workflow этапа 5

## 5. Места хранения секретов (ко всем этапам, самих секретов здесь НЕТ)

- terraform.tfvars (cloud_id, folder_id, sa_key_file) - локально в
  src/01_diploma-tf/, в .gitignore, НЕ в репозитории.
- Шаблон без секретов: src/01_diploma-tf/terraform.tfvars.example
- SSH-ключ для ВМ: локально по пути из переменной ssh_public_key_path
  (по умолчанию ~/.ssh/terraform-yc.pub)
- SA JSON-ключ для Terraform/CI: локально + GitHub Secrets репозитория
  diploma-tf (имена секретов зафиксировать при создании)
- DockerHub creds: GitHub Secrets репозитория diploma-app
  (DOCKERHUB_USERNAME, DOCKERHUB_TOKEN)
- kubeconfig: GitHub Secrets репозиториев diploma-k8s и diploma-app
  (KUBECONFIG_B64)

---

## 6. Этап 1. Terraform-инфраструктура (репо diploma-tf)

Требования:
- backend "s3": бакет ЯО + YDB-таблица для блокировки
- apply с нуля поднимает VPC + ВМ + state-bucket; destroy сносит всё
  без ручных шагов

Решения этапа (используются только здесь):
- ВМ 2 CPU / 4 GB RAM (может быть увеличено на этапе 2 при тормозах
  Kubespray), core_fraction 20
- SA + бакет + YDB-таблица создаёт bootstrap-скрипт ОДИН раз вручную
  (state-бэкенд живёт между destroy/apply, его destroy не трогает);
  Terraform управляет только VPC + ВМ
- SA для CI/CD (этап 4) описывается ресурсами Terraform в sa.tf

Скриншоты этапа (в img/, имена 23-01_*, ссылка в README этапа):
- 23-01_tf_init - terraform init, backend S3 инициализирован
- 23-01_tf_apply - terraform apply, ресурсы созданы, outputs с IP
- 23-01_yc_resources - консоль YC или yc vpc subnet list + yc compute
  instance list: VPC, 3 подсети, 3 ВМ
- 23-01_state_bucket - Object Storage: terraform.tfstate в бакете
- 23-01_tf_destroy - terraform destroy отработал без ручных шагов

Структура кода этапа:
+++text
src/01_diploma-tf/
  bootstrap.sh / bootstrap.ps1  - SA + ключ + state-бакет + YDB-таблица
  main.tf      - provider, backend s3 (bucket: nikolay-modonov-diploma-tf-state)
  network.tf   - network diploma-net + подсети a/b/d (10.10.1-3.0/24)
  vms.tf       - 3 ВМ k8s_node (node-a/node-b/node-d) по зонам
  variables.tf - cloud_id, folder_id, default_zone, sa_key_file, ssh_public_key_path
  outputs.tf   - публичные/приватные IP ВМ, id сети/подсетей
+++

Статус этапа: В РАБОТЕ
- main.tf, network.tf, variables.tf, vms.tf - готово
- outputs.tf - в работе
- bootstrap.sh / bootstrap.ps1 - в работе
- Скриншоты - не сняты

## 7. Этап 2. Kubernetes-кластер (репо diploma-ansible)

- Берём Kubespray (release или submodule)
- inventory.ini заполняется из TF outputs этапа 1
- ansible-playbook -i inventory.ini cluster.yml -> 1 control-plane + 2 worker, calico
- kubeconfig забираем с первой ВМ (scp/ansible fetch)
- Критерий: kubectl get pods --all-namespaces без ошибок, все ноды Ready
- Скриншоты (имена 23-02_*): описать по заданию при выполнении
- Статус: НЕ НАЧАТ

## 8. Этап 3. Тестовое приложение (репо diploma-app)

- index.html со статикой, nginx.conf (root /usr/share/nginx/html, listen 80)
- Dockerfile: FROM nginx:stable-alpine + COPY nginx.conf и index.html
- Локально: docker build + docker push в DockerHub: <user>/diploma-app:latest
- Критерий: docker run -p 8080:80 <image> отдаёт страницу
- Статус: НЕ НАЧАТ

## 9. Этап 4. Мониторинг + деплой (репо diploma-k8s)

- helm install kube-prometheus-stack
- Grafana наружу: Service type=LoadBalancer (проще, без Ingress-контроллера);
  задание требует Ingress - при придирке добавляем ingress-nginx и Ingress
- Приложение: Deployment (replicas 2) + Service LoadBalancer port 80
- CI/CD-terraform workflow в diploma-tf: plan на PR, apply на merge в main,
  креды ЯО - SA JSON key в Secrets
- Критерий: Grafana открывается и показывает дашборды K8s, приложение
  открывается по IP LB, в Actions есть успешный apply
- Статус: НЕ НАЧАТ

## 10. Этап 5. CI/CD (репо diploma-app, .github/workflows/)

- Workflow на push в main: build -> tag latest -> docker push ->
  kubectl set image deployment/app
- Workflow на тег v*: build -> tag <тег> -> docker push -> set image + rollout
- kubectl через KUBECONFIG_B64 из Secrets
- Критерий: Actions зелёные; коммит -> новый latest в DockerHub;
  тег v1.0.0 -> образ по тегу + обновлённый Deployment в кластере
- Статус: НЕ НАЧАТ

---

## 11. Порядок работы

- Этапы: 1 -> 2 -> 3 -> 4 -> 5. Этап 3 можно делать параллельно с 1-2.
- После каждого этапа: обновить раздел "Статус" соответствующего этапа
  в этом файле, сложить скриншоты в img/ этапа, заполнить README этапа.