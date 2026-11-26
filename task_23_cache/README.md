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
- Облако: Yandex Cloud (ЯО)
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
- Среда выполнения
  - Рабочая машина: Windows-десктоп. Используется: git, Terraform,
    Yandex Cloud CLI. Ничего больше локально не ставим.
    Остальные машины - ВМ в ЯО
  - Ansible (Kubespray, этап 2) запускается с node-a (первая ВМ этапа 1).
    kubectl, helm, jq ставятся там же - нужны для проверки кластера и
    деплоя (этапы 2, 4).
  - Docker-сборка приложения (этап 3) выполняется в GitHub Actions,
    локальный Docker не используется.
  - Доступ к ВМ с десктопа - ssh (терминал есть всегда).
  - Правило: всё, что можно выполнить в облаке или в CI, выполняется там,
    а не локально.

## 2. Репозитории (ко всем этапам)

- Несколько отдельных репозиториев
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

- ВМ: standard-v2, 4 CPU / 8 GB RAM, core_fraction 20, диск network-ssd 50
  GB, Ubuntu 22.04, 3 шт (ru-central1-a/b/d)
- K8s: 1 control-plane + 2 worker, CNI calico (Kubespray stacked)
- Ansible (Kubespray) запускается с node-a, отдельная mgmt-ВМ не создаётся
- Backend TF state: S3-бакет nikolay-modonov-diploma-tf-state, блокировка
  use_lockfile = true, у бакета включено версионирование. YDB не
  используется.
- SA diploma-sa и state-бакет созданы вручную один раз, вне Terraform.
  terraform destroy их не трогает.
- diploma-sa имеет роли на фолдере: editor, storage.admin, vpc.admin,
  compute.admin, load-balancer.admin, kms.keys.encrypterDecrypter,
  iam.serviceAccounts.admin. 
  Проверено list-access-bindings, роли выданы. 
  Проверка: yc resource-manager folder list-access-bindings <folder_id>. 
  Недостающие можно выдать через
  yc resource-manager folder add-access-binding (см. команду выше).
- Роль container-registry.admin у SA не нужна (registry - DockerHub).
- Провайдер yandex в main.tf - пустой блок, читает переменные окружения
  YC_CLOUD_ID, YC_FOLDER_ID, YC_SERVICE_ACCOUNT_KEY_FILE, YC_ZONE.
- Registry: НАЧИНАЕМ С DockerHub (публичный образ, imagePullSecret не нужен).
  ВНИМАНИЕ: задание требует приватный Yandex Container Registry. Если
  преподаватель придирётся - переключаемся на YCR на этапе 3.
- CI/CD-terraform (требование задания об автоприменении TF) закрывается 
  GitHub Actions workflow в diploma-tf: plan на PR, apply при merge в main.
  Отдельный Atlantis не нужен.
- Код и конфигурации отдельных репо и создаваемых
- TF outputs (IP ВМ, id подсетей) -> ansible inventory этапа 2
- kubeconfig этапа 2 -> GitHub Secrets -> этапы 4 и 5
- имя образа этапа 3 -> Deployment этапа 4 и workflow этапа 5
- SA JSON-ключ (создан вручную, вне этапов) -> GitHub Secrets -> CI/CD-terraform
- DockerHub/YCR creds -> GitHub Secrets -> workflow этапа 5

## 5. Места хранения секретов (ко всем этапам, самих секретов здесь НЕТ)

- ~/.secrets/netology/diploma/key.json - SA JSON-ключ diploma-sa
- ~/.secrets/netology/diploma/env.sh - для Linux (node-a): экспортирует
  YC_CLOUD_ID, YC_FOLDER_ID, YC_SERVICE_ACCOUNT_KEY_FILE, YC_ZONE
- ~/.secrets/netology/diploma/env.ps1 - те же переменные для PowerShell
  на десктопе
- ~/.ssh/terraform-yc.pub - ssh-ключ для ВМ, путь в переменной
  ssh_public_key_path
- terraform.tfvars НЕ используется, terraform.tfvars.example удалён:
  переменных под него в коде не осталось
- SA JSON-ключ для CI/CD-terraform: GitHub Secrets репозитория diploma-tf
  (имена секретов зафиксировать при создании)
- DockerHub creds: GitHub Secrets репозитория diploma-app
  (DOCKERHUB_USERNAME, DOCKERHUB_TOKEN)
- kubeconfig: GitHub Secrets репозиториев diploma-k8s и diploma-app
  (KUBECONFIG_B64)

---

## 6. Этап 1. Terraform-инфраструктура (репо diploma-tf, директория
src/01_diploma-tf репо сдачи)

Требования:
- backend "s3": бакет ЯО, блокировка use_lockfile = true, у бакета
  включено версионирование (YDB не используется)
- apply с нуля поднимает VPC + ВМ; destroy сносит всё без ручных шагов

Решения этапа (используются только здесь):
- ВМ 4 CPU / 8 GB RAM, core_fraction 20, диск network-ssd 50 GB
- SA (diploma-sa) и state-бакет (nikolay-modonov-diploma-tf-state)
  созданы вручную ОДИН раз, вне Terraform; destroy их не трогает.
  Terraform управляет только VPC + ВМ
- Провайдер yandex - пустой блок, читает переменные окружения
  (YC_CLOUD_ID, YC_FOLDER_ID, YC_SERVICE_ACCOUNT_KEY_FILE, YC_ZONE)

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
  main.tf      - провайдер (пустой блок), backend s3
                 (bucket: nikolay-modonov-diploma-tf-state,
                 use_lockfile = true), data-источник ubuntu-2204-lts
  network.tf   - network diploma-net + подсети a/b/d (10.10.1-3.0/24)
  vms.tf       - 3 ВМ k8s_node (node-a/node-b/node-d) по зонам
  variables.tf - ssh_public_key_path
  outputs.tf   - публичные/приватные IP ВМ, id сети/подсетей
+++

Статус этапа: В РАБОТЕ
- network.tf, vms.tf - готово
- main.tf, variables.tf - в работе (перевод на env-переменные)
- outputs.tf - в работе
- bootstrap.sh / bootstrap.ps1 - удалить (SA и бакет уже созданы вручную)
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
- Первая сборка и пуш образа - одноразовый запуск GitHub Actions
  workflow в diploma-app (workflow_dispatch): <user>/diploma-app:latest
- Критерий: образ в DockerHub; docker run -p 8080:80 <image> на node-a
  отдаёт страницу
- ВНИМАНИЕ: после Kubespray на нодах стоит containerd, команды docker
  там может не быть. Если docker на node-a отсутствует - критерий
  проверять через kubectl run + port-forward или поставить nerdctl
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