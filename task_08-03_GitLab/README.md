# Домашнее задание к занятию "GitLab" - `Модонов Николай`

### Задание 1
Что нужно сделать:

1. Разверните GitLab локально, используя Vagrantfile и инструкцию, описанные в этом репозитории.
2. Создайте новый проект и пустой репозиторий в нём.
3. Зарегистрируйте gitlab-runner для этого проекта и запустите его в режиме Docker. Раннер можно регистрировать и запускать на той же виртуальной машине, на которой запущен GitLab.

В качестве ответа в репозиторий шаблона с решением добавьте скриншоты с настройками раннера в проекте.

Решение:
1. ![Скриншот с раннером](https://github.com/NikolayModonov/task_08-03_GitLab/blob/main/runner.jpg)
2. Vagrantfile
```
# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_EXPERIMENTAL'] = 'disks'

Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"
  
  config.vm.network "private_network", ip: "10.10.10.3"
  
  config.vm.disk :disk, size: "15GB", primary: true
  
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "6144"
    vb.cpus = 2
  end

    config.vm.provision "shell", inline: <<-SHELL
    set -e
    export DEBIAN_FRONTEND=noninteractive
    
    # Настройка кэша Apt (чтобы не качать deb-пакеты заново)
    mkdir -p /vagrant/apt_cache
    #chown _apt /vagrant/apt_cache
    echo 'Dir::Cache::archives "/vagrant/apt_cache/";' > /etc/apt/apt.conf.d/99-vagrant-cache
    
    # Установка зависимостей (скачанные пакеты сохранятся в /vagrant/apt_cache)
    apt-get update
    apt-get install -y docker.io curl openssh-server ca-certificates tzdata perl

    # Настройка кэша Docker (чтобы не качать образы заново)
    mkdir -p /vagrant/docker_cache
    pull_and_cache() {
      image=$1
      
      docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^$image$" && return 0
      
      tar_path="/vagrant/docker_cache/$(echo "$image" | tr '/:' '_').tar"
      if [ -f "$tar_path" ]; then
        docker load -i "$tar_path"
      else
        docker pull "$image"
        docker save -o "$tar_path" "$image"
      fi
    }

    # Загружаем/качаем образы
    pull_and_cache "gitlab/gitlab-ce:latest"
    pull_and_cache "gitlab/gitlab-runner:latest"
    pull_and_cache "golang:1.17"
    pull_and_cache "docker:latest"

    # Установка GitLab через Docker (проверяем, не запущен ли уже)
    if [ ! $(docker ps -a --filter "name=^/gitlab$" --format '{{.Names}}') ]; then
      docker run --detach \\
        --hostname gitlab.localdomain \\
        --publish 80:80 \\
        --name gitlab \\
        --restart always \\
        --volume /srv/gitlab/config:/etc/gitlab \\
        --volume /srv/gitlab/logs:/var/log/gitlab \\
        --volume /srv/gitlab/data:/var/opt/gitlab \\
        --shm-size 256m \\
        gitlab/gitlab-ce:latest
    else
      echo "GitLab container already exists."
    fi

    # Настройка hosts
    echo -e "10.10.10.3\tdebian-bookworm\tdebian-bookworm" >> /etc/hosts
    echo -e "10.10.10.3\tgitlab.localdomain\tgitlab" >> /etc/hosts

    # Очистка старого раннера, если ВМ не пересоздавалась
    docker rm -f gitlab-runner 2>/dev/null || true
    rm -rf /srv/gitlab-runner/config/*

    echo "Stage: Waiting for GitLab Database"
    while true; do
      docker exec gitlab gitlab-rails runner "puts ActiveRecord::Base.connection.execute('SELECT 1').values.first.first" > /dev/null 2>&1 && break
      sleep 10
    done

    echo "Stage: Creating project and runner"
    PAT=$(docker exec gitlab gitlab-rails runner "user = User.find_by(username: 'root'); pat = PersonalAccessToken.new(user: user, name: 'runner-reg', scopes: [:api], expires_at: 30.days.from_now); pat.save!; puts pat.token")
    curl -s --request POST --header "PRIVATE-TOKEN: $PAT" "http://gitlab.localdomain/api/v4/projects" --data "name=gitlab-hw&path=gitlab-hw" > /dev/null
    PROJ_ID=$(curl -s --header "PRIVATE-TOKEN: $PAT" "http://gitlab.localdomain/api/v4/projects?search=gitlab-hw" | grep -o '"id":[0-9]*' | head -n 1 | grep -o '[0-9]*')
    RUNNER_TOKEN=$(curl -s --request POST --header "PRIVATE-TOKEN: $PAT" "http://gitlab.localdomain/api/v4/user/runners" --data "runner_type=project_type&project_id=$PROJ_ID" | grep -o '"token":"[^"]*"' | grep -o 'glrt-[a-zA-Z0-9._-]*')

    echo "Stage: Registering runner"
    docker run --rm --network host \
    -v /srv/gitlab-runner/config:/etc/gitlab-runner \
    -v /var/run/docker.sock:/var/run/docker.sock \
    gitlab/gitlab-runner:latest register \
    --non-interactive \
    --url "http://gitlab.localdomain" \
    --token "$RUNNER_TOKEN" \
    --executor "docker" \
    --docker-image "alpine:latest" \
    --docker-privileged=true \
    --docker-volumes "/cache,/var/run/docker.sock:/var/run/docker.sock" \
    --docker-extra-hosts "gitlab.localdomain:10.10.10.3"

    echo "Stage: Starting runner container"
    docker run -d --name gitlab-runner --restart always \
    --network host \
    -v /srv/gitlab-runner/config:/etc/gitlab-runner \
    -v /var/run/docker.sock:/var/run/docker.sock \
    gitlab/gitlab-runner:latest

    echo "Stage: Extracting root credentials"
    ROOT_PASS=$(docker exec gitlab cat /etc/gitlab/initial_root_password | grep "Password:" | awk '{print $2}')
    
    echo "=================================================="
    echo "Provisioning complete"
    echo "URL: http://gitlab.localdomain"
    echo "Login: root"
    echo "Password: $ROOT_PASS"
    echo "=================================================="

  SHELL
end

```

---

### Задание 2

Что нужно сделать:
1. Запушьте репозиторий на GitLab, изменив origin. Это изучалось на занятии по Git.
2. Создайте .gitlab-ci.yml, описав в нём все необходимые, на ваш взгляд, этапы.

В качестве ответа в шаблон с решением добавьте:
- файл gitlab-ci.yml для своего проекта или вставьте код в соответствующее поле в шаблоне;
- скриншоты с успешно собранными сборками.



Решение:
1. ![Скриншот с пайплайном 1](https://github.com/NikolayModonov/task_08-03_GitLab/blob/main/pipeline_1.jpg)
2. ![Скриншот с пайплайном 1](https://github.com/NikolayModonov/task_08-03_GitLab/blob/main/pipeline_2.jpg)
3. Файл .gitlab-ci.yml

```
stages:
  - test
  - build

test:
  stage: test
  image: golang:1.17
  script:
    - go test .

build:
  stage: build
  image: docker:latest
  script:
    - docker build .
```

