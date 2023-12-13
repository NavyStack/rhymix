# Rhymix with NGINX and Treafik <br> (라이믹스 엔진엑스 도커, Treafik)

[![Docker Image CI](https://github.com/Navystack/rhymix/actions/workflows/docker-image.yml/badge.svg)](https://github.com/Navystack/rhymix/actions/workflows/docker-image.yml)

[Traefik 리버스 프록시 설명](https://navystack.com/2023/11/라이믹스-예제로-배우는-traefik-리버스-프록시-정리/) <br><br>
[Docker Hub 바로가기](https://hub.docker.com/r/navystack/rhymix) <br><br>
[관련 Github 바로가기](https://github.com/NavyStack/rhymix) <br><br>
[NavyStack 블로그](https://navystack.com/) <br><br>
[Rhymix-Github 바로가기](https://github.com/rhymix/rhymix)

## 왜 Rhymix와 Nginx인가요?

> 한국에서 인기있는 라이믹스와 강력한 Nginx의 웹서버의 힘을 느껴보세요. <br> 그리고 제가 아파치를 모릅니다.

[라이믹스에 대해서 더 알아보기](https://rhymix.org/about)

## 이미지에 포함된 Nginx 모듈은 무엇인가요?

기본적으로 Debian 기반의 Nginx 공식 [Dockerfile](https://github.com/nginxinc/docker-nginx/blob/4bf0763f4977fff7e9648add59e0540088f3ca9f/mainline/debian/Dockerfile)을 참고해서 이미지를 만듭니다. <br>
필요하다고 생각하는 모듈은 멀티스테이지를 통해서 가져오기 때문에 이미지의 크기가 비교적 작습니다.

`ngx_pagespeed`, `ngx_http_brotli`, `ngx_cache_purge` 모듈이 [포함](https://github.com/NavyStack/rhymix/blob/bf1c17cfa1eefd5ae6e0f578ebe909f39f6bca0f/Dockerfile#L139) 되어 있습니다. <br>
아래는 컨테이너에서 `nginx -V 2>&1 | xargs -n1 | grep module$` 의 화면입니다.

```consol
--with-http_addition_module
--with-http_auth_request_module
--with-http_dav_module
--with-http_flv_module
--with-http_gunzip_module
--with-http_gzip_static_module
--with-http_mp4_module
--with-http_random_index_module
--with-http_realip_module
--with-http_secure_link_module
--with-http_slice_module
--with-http_ssl_module
--with-http_stub_status_module
--with-http_sub_module
--with-http_v2_module
--with-http_v3_module
--with-mail_ssl_module
--with-stream_realip_module
--with-stream_ssl_module
--with-stream_ssl_preread_module
```

## 지원되는 태그

|       Docker Tag        | Base OS | Rhymix | PHP_VERSION |  NGINX_VERSION   | NJS_VERSION |  etc.  |
| :---------------------: | :-----: | :----: | :---------: | :--------------: | :---------: | :----: |
| navystack/rhymix:latest |   deb   | 2.1.10 |     8.2     | Mainline(1.25.3) |    0.8.2    |        |
|  navystack/rhymix:tls   |   deb   | 2.1.10 |     8.2     | Mainline(1.25.3) |    0.8.2    | DB TLS |

<br>

`navystack/rhymix:tls`는 [DigiCert](https://learn.microsoft.com/ko-kr/azure/mysql/single-server/concepts-ssl-connection-security) Root CA 입니다. [여기에서](https://github.com/NavyStack/rhymix/blob/e1f48bf3ce82b8ecbc632acbae013866cafdbb0c/Dockerfile-Extras/Dockerfile-tls#L10) 확인 가능합니다.

\*[Azure Database for MySQL](https://learn.microsoft.com/ko-kr/azure/mysql/single-server/concepts-ssl-connection-security)
<br>

## 이미지 사용하기

Rhymix(라이믹스)는 MySQL 혹은 MariaDB가 필요합니다. 이 레포에서는 예제로 MySQL을 사용합니다. <br>
또한, 모던 리버스 프록시인 Traefik을 통해서 연결하고, 인증서 관리를 Traefik에서 합니다. <br><br>
현재 Traefik 설정에 Http3(Quic) 설정을 해두었습니다. 따라서 `443/UDP`도 방화벽에서 허용하셔야합니다.

필요한 포트 : `80/TCP`, `443/TCP`, `443/UDP`

### 레포지토리를 복제하기

`git clone https://github.com/NavyStack/rhymix.git`

그리고 rhymix의 경로로 이동합니다.

---

### Step 1. `docker-compose.yml`를 수정하기

이동한 경로에 `docker-compose.yml` 파일이 있습니다. `1. #수정 부분 변경` `2. 인증서 부분 환경에 맞게 변경 ` 두 가지만 하시면 됩니다. 기본적으로 www.example.com 로 접속하면 example.com 301 리디렉션 걸려있고, https 자동 적용입니다.

---

### Step 2. Docker Network를 만들기

`docker-compose.yml` 파일에 `external: true` 선언이 되어있고, Traefik으로 리버스 프록싱을 하기 위해서 도커 네트워크를 만들어야 합니다.

`docker network create traefik-network`

---

### Step 3. traefik-certificates/acme.json 권한 수정

`chmod 600 traefik-certificates/acme.json`

트래픽은 600 권한으로 되어있어야 인증서가 발급됩니다.

---

### Step 4. Docker 컨테이너 실행하기

`docker compose up -d`

---

### Step 5.(끝) `Step .1`에서 수정한 도메인으로 접속하면 라이믹스 설치화면이 나옵니다.

[그럴리가 없는데 안되면 문의 남겨주세요](https://navystack.com/nsboard/) 여유가 될 때 답변 드리겠습니다.

---

## 기타

- Traefik:v2.10 버전의 문법입니다.
- "3.9" 버전이므로 Docker-Swarm으로도 가능하나, 아시겠지만 Docker-Swarm의 고질적인 원본 IP 복원 문제가 있습니다.
- 업데이트 전 반드시 백업하세요. 컨테이너 이미지와 Dockerfile은 있는 그대로 제공됩니다.

### docker-compose.yml

```docker-compose.yml
version: "3.9"
services:
  rhymix-db:
    image: mysql:8.0
    restart: unless-stopped

    logging:
      options:
        max-size: "10m"

    environment:
      MYSQL_USER: rhymix ## 수정
      MYSQL_PASSWORD: powerpassword ## 수정
      MYSQL_DATABASE: rhymix ## 수정
      MYSQL_ROOT_PASSWORD: powerpassword ## 수정

    volumes:
      - rhymix-db:/var/lib/mysql

    networks:
      - traefik-network

  rhymix:
    image: navystack/rhymix:latest
    restart: unless-stopped
    depends_on:
      - rhymix-db

    logging:
      options:
        max-size: "10m"

    labels:
      - "traefik.enable=true"
      - "traefik.docker.network=traefik-network"

      - "traefik.http.services.rhymix-srv.loadbalancer.server.port=80"
      - "traefik.http.services.rhymix-srv.loadbalancer.passhostheader=true"

      - "traefik.http.middlewares.www-redir.redirectregex.regex=^https://www.(.*)"
      - "traefik.http.middlewares.www-redir.redirectregex.replacement=https://$${1}"
      - "traefik.http.middlewares.www-redir.redirectregex.permanent=true"

      - "traefik.http.middlewares.compresstraefik.compress=true"

      - "traefik.http.routers.rhymix-rt.rule=Host(`example.com`) || Host(`www.example.com`)" ## 수정
      - "traefik.http.routers.rhymix-rt.entrypoints=websecure"
      - "traefik.http.routers.rhymix-rt.service=rhymix-srv"
      - "traefik.http.routers.rhymix-rt.middlewares=www-redir, compresstraefik"

      - "traefik.http.routers.rhymix-rt.tls=true"
      - "traefik.http.routers.rhymix-rt.tls.certresolver=letsencrypt" ## 수정
      - "traefik.http.routers.rhymix-rt.tls.domains[0].main=example.com" ## 수정
      - "traefik.http.routers.rhymix-rt.tls.domains[0].sans=*.example.com" ## 수정

    volumes:
      - rhymix-data:/var/www/html

    networks:
      - traefik-network

  traefik:
    image: traefik:v2.10
    restart: unless-stopped
    logging:
      options:
        max-size: "10m"
    command:
      - "--log.level=INFO"
      - "--accesslog=true"
      - "--api.dashboard=true"
      - "--ping=true"
      - "--ping.entrypoint=ping"

      - "--entryPoints.ping.address=:8082"
      - "--entryPoints.web.address=:80"
      - "--entryPoints.websecure.address=:443"

      - "--entryPoints.web.http.redirections.entryPoint.to=websecure"
      - "--entrypoints.web.http.redirections.entryPoint.scheme=https"
      - "--entrypoints.web.http.redirections.entrypoint.permanent=true"

      - "--providers.docker=true"
      - "--providers.docker.watch=true"
      - "--providers.docker.network=traefik-network"
      - "--providers.docker.endpoint=unix:///var/run/docker.sock"
      - "--providers.docker.exposedByDefault=false"

      # Let's Encrypt ACME 설정
      - "--certificatesresolvers.letsencrypt.acme.tlschallenge=true" # DNS Challenge 사용시 주석처리 하고 밑에 Let's Encrypt ACME DNS Challenge (CLoudflare) 주석 해제 && # environment: # CF_DNS_API_TOKEN: 주석 해제

      - "--certificatesresolvers.letsencrypt.acme.keyType=EC256"
      - "--certificatesresolvers.letsencrypt.acme.email=webmaster@example.com" # 여기 이메일을 본인의 이메일로 수정
      - "--certificatesresolvers.letsencrypt.acme.storage=/etc/traefik/acme/acme.json"

      # Let's Encrypt ACME DNS Challenge (CLoudflare)
      #- "--certificatesResolvers.letsencrypt.acme.dnsChallenge=true"
      #- "--certificatesResolvers.letsencrypt.acme.dnsChallenge.provider=cloudflare"
      #- "--certificatesResolvers.letsencrypt.acme.dnsChallenge.resolvers=1.1.1.1:53,8.8.8.8:53"
      #- "--certificatesresolvers.letsencrypt.acme.dnschallenge.delaybeforecheck=0"

      # Prometheus 메트릭 설정
      - "--metrics.prometheus=true"
      - "--metrics.prometheus.buckets=0.1,0.3,1.2,5.0"
      - "--metrics.prometheus.addServicesLabels=true"
      - "--metrics.prometheus.addrouterslabels=true"
      - "--metrics.prometheus.addEntryPointsLabels=true"

      # 버전 확인 및 익명 사용 통계 설정
      - "--global.checkNewVersion=true"
      - "--global.sendAnonymousUsage=false"

      # HTTP3 설정
      - "--experimental.http3=true"
      - "--entrypoints.websecure.http3"
      - "--entrypoints.websecure.http3.advertisedport=443"

    # environment:
    # CF_DNS_API_TOKEN: # DNS Challenge 사용시 주석!해!제!

    healthcheck:
      test: ["CMD", "wget", "http://localhost:8082/ping", "--spider"]
      interval: 10s
      timeout: 2s
      retries: 3
      start_period: 5s

    labels:
      - "traefik.enable=true"
      - "traefik.http.services.dashboard.loadbalancer.server.port=8080"
      - "traefik.http.services.dashboard.loadbalancer.passhostheader=true"

      - "traefik.http.routers.dashboard.rule=Host(`web.example.com`)" ## 수정
      - "traefik.http.routers.dashboard.entrypoints=websecure"
      - "traefik.http.routers.dashboard.service=api@internal"
      - "traefik.http.routers.dashboard.tls=true"
      - "traefik.http.routers.dashboard.tls.certresolver=letsencrypt"

    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./traefik-certificates:/etc/traefik/acme

    networks:
      - traefik-network

    ports:
      - target: 80
        published: 80
        mode: host
      - target: 443
        published: 443
        mode: host
        protocol: tcp
      - target: 443
        published: 443
        mode: host
        protocol: udp

volumes:
  rhymix-data:
  rhymix-db:

networks:
  traefik-network:
    external: true
```

### default.conf

```default.conf
upstream rhymix {
    server 127.0.0.1:9000;
    keepalive 2;
}

server {
    listen 80;
    server_name _;
    server_tokens off;
    root /var/www/html/;
    index index.php index.html index.htm;
    client_max_body_size 64M;

    set_real_ip_from 0.0.0.0/0;
    real_ip_header X-Forwarded-For;
    real_ip_recursive on;

    #################
    # Gzip Settings #
    #################
    gzip on;
    gzip_disable "msie6";
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 1;
    gzip_buffers 16 8k;
    gzip_http_version 1.1;
    gzip_min_length 1024;
    gzip_types
    text/plain
    text/css
    text/js
    text/xml
    text/javascript
    application/javascript
    application/x-javascript
    application/json
    application/xml
    application/xml+rss
    image/svg+xml;

    ###################
    # Brotli Settings #
    ###################

    brotli on;
    brotli_comp_level 6;
    brotli_static on;
    brotli_min_length 1024;
    brotli_types
    text/plain
    text/css
    text/js
    text/xml
    text/javascript
    application/javascript
    application/x-javascript
    application/json
    application/xml
    application/xml+rss
    image/svg+xml;

    ######################
    # Pagespeed Settings #
    ######################

    pagespeed standby;
    pagespeed FileCachePath /var/run/ngx_pagespeed_cache;
    pagespeed XHeaderValue "";

    ########################
    # Virtual Host Configs #
    ########################

    # block direct access to templates, XML schemas, config files, dotfiles, environment info, etc.
    location ~ ^/modules/editor/(skins|styles)/.+\.html$ {
        # pass
    }
    location ~ ^/(addons|common/tpl|files/ruleset|(m\.)?layouts|modules|plugins|themes|widgets|widgetstyles)/.+\.(html|xml|blade\.php)$ {
        return 404;
    }
    location ~ ^/files/(attach|config|cache)/.+\.(ph(p|t|ar)?[0-9]?|p?html?|cgi|pl|exe|[aj]spx?|inc|bak)$ {
        return 404;
    }
    location ~ ^/files/(env|member_extra_info/(new_message_flags|point))/ {
        return 404;
    }
    location ~ ^/(\.git|\.ht|\.travis|codeception\.|composer\.|Gruntfile\.js|package\.json|CONTRIBUTING|COPYRIGHT|LICENSE|README|\.user\.ini) {
        return 404;
    }

    # fix incorrect relative URLs (for legacy support)
    location ~ ^/(.+)/(addons|files|layouts|m\.layouts|modules|widgets|widgetstyles)/(.+) {
        try_files $uri $uri/ /$2/$3;
    }

    # fix incorrect minified URLs (for legacy support)
    location ~ ^/(.+)\.min\.(css|js)$ {
        try_files $uri $uri/ /$1.$2;
    }

    # fix download URL when other directives for static files are present
    location ~ ^/files/download/ {
        try_files $uri $uri/ /index.php$is_args$args;
    }

    # all other short URLs
    location / {
        try_files $uri $uri/ /index.php$is_args$args;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location ~ \.php$ {

        try_files $uri =404;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PHP_VALUE "memory_limit=256M;
                                 max_execution_time=360;
                                 max_input_time=30;
                                 max_input_vars=2000;
                                 post_max_size=64M;
                                 upload_max_filesize=32M;
                                 date.timezone=Asia/Seoul;
                                 display_errors=off;
                                 cgi.fix_pathinfo=0;";
        fastcgi_pass rhymix;
        fastcgi_read_timeout 3600;
        fastcgi_send_timeout 3600;

        fastcgi_hide_header X-Powered-By;
    }

    location ~* \.(?:jpg|jpeg|png|gif|avif|webp|ico|css|js|eot|ttf|woff|woff2)$ {
        access_log off;
        try_files $uri $uri/ /index.php?$query_string;
        add_header Cache-Control "public, max-age=31536000";
        add_header Access-Control-Allow-Origin *;
    }
}
```

## 라이선스

My contributions are licensed under the MIT License <br>

SPDX-License-Identifier: MIT OR GNU GPLv2

모든 Docker 이미지와 마찬가지로, 여기에는 다른 라이선스(예: 기본 배포판의 Bash 등 및 포함된 기본 소프트웨어의 직간접적인 종속성)가 적용되는 다른 소프트웨어도 포함될 수 있습니다.

사전 빌드된 이미지 사용과 관련하여, 이 이미지를 사용할 때 이미지에 포함된 모든 소프트웨어에 대한 관련 라이선스를 준수하는지 확인하는 것은 이미지 사용자의 책임입니다.

기타 모든 상표는 각 소유주의 재산이며, 달리 명시된 경우를 제외하고 본문에서 언급한 모든 상표 소유자 또는 기타 업체와의 제휴관계, 홍보 또는 연관관계를 주장하지 않습니다.
