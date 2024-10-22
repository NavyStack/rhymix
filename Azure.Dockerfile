FROM amazonlinux:2023.6.20241010.0 AS nginx-moduler
ARG NGINX_VERSION=1.25.3
ARG PHP_VERSION=PHP8.29
ARG TARGETARCH
ARG PSOL=jammy

RUN dnf -y install \
            gcc \
            zlib-devel \
            openssl-devel \
            make \
            pcre-devel \
            libxml2-devel \
            libxslt-devel \
            libgcrypt-devel \
            gd-devel \
            perl-ExtUtils-Embed \
            xz \
            wget \
            git \
            gcc-c++ \
            unzip \
            libuuid-devel \
            tar

RUN mkdir -p /opt/build-stage

WORKDIR /opt/build-stage
RUN wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz

RUN git clone --recurse-submodules -j8 https://github.com/google/ngx_brotli.git && \
    cd ngx_brotli && git reset --hard a71f9312c2deb28875acc7bacfdd5695a111aa53 && \
    cd /opt/build-stage

RUN git clone --recurse-submodules -j8 https://github.com/nginx-modules/ngx_immutable.git && \
    cd ngx_immutable && git reset --hard dab3852a2c8f6782791664b92403dd032e77c1cb && \
    cd /opt/build-stage

RUN git clone --recurse-submodules -j8 https://github.com/nginx-modules/ngx_cache_purge.git && \
    cd ngx_cache_purge && git reset --hard a84b0f3f082025dec737a537a9a443bdd6d6af9d && \
    cd /opt/build-stage

RUN if [ "$TARGETARCH" = "amd64" ]; then \
    wget https://www.tiredofit.nl/psol-${PSOL}.tar.xz && \
    git clone --depth=1 https://github.com/apache/incubator-pagespeed-ngx.git && \
    tar xvf psol-${PSOL}.tar.xz && \
    mv psol incubator-pagespeed-ngx && \
    tar zxvf nginx-${NGINX_VERSION}.tar.gz; \
    fi

RUN if [ "$TARGETARCH" = "arm64" ]; then \
    wget https://gitlab.com/gusco/ngx_pagespeed_arm/-/raw/master/psol-1.15.0.0-aarch64.tar.gz && \
    git clone --depth=1 https://github.com/apache/incubator-pagespeed-ngx.git && \
    tar xvf psol-1.15.0.0-aarch64.tar.gz && \
    mv psol incubator-pagespeed-ngx && \
    sed -i 's/x86_64/aarch64/' incubator-pagespeed-ngx/config && \
    sed -i 's/x64/aarch64/' incubator-pagespeed-ngx/config && \
    sed -i 's/-luuid/-l:libuuid.so.1/' incubator-pagespeed-ngx/config && \
    tar zxvf nginx-${NGINX_VERSION}.tar.gz; \
    fi

WORKDIR /opt/build-stage/nginx-${NGINX_VERSION}
RUN ./configure --with-compat \
    --add-dynamic-module=../ngx_brotli \
    --add-dynamic-module=../incubator-pagespeed-ngx \
    --add-dynamic-module=../ngx_immutable \
    --add-dynamic-module=../ngx_cache_purge && \
    make modules && \
    mkdir -p /usr/lib/nginx/modules/ && \
    cp /opt/build-stage/nginx-${NGINX_VERSION}/objs/*.so /usr/lib/nginx/modules/

RUN mkdir -p /tmp/standby/nginx_modules && \
    cp /usr/lib/nginx/modules/ngx_http_brotli_filter_module.so /tmp/standby/nginx_modules/ && \
    cp /usr/lib/nginx/modules/ngx_http_brotli_static_module.so /tmp/standby/nginx_modules/ && \
    cp /usr/lib/nginx/modules/ngx_http_immutable_module.so /tmp/standby/nginx_modules/ && \
    cp /usr/lib/nginx/modules/ngx_http_cache_purge_module.so /tmp/standby/nginx_modules/ && \
    cp /usr/lib/nginx/modules/ngx_pagespeed.so /tmp/standby/nginx_modules/

RUN git clone --depth=1 https://github.com/rhymix/rhymix.git /usr/src/rhymix
RUN mkdir -p /usr/src/rhymix/files
RUN chmod -R 1777 /usr/src/rhymix/files
RUN wget --no-check-certificate https://dl.cacerts.digicert.com/DigiCertGlobalRootCA.crt.pem -P /usr/src/rhymix
RUN chmod 600 /usr/src/rhymix/DigiCertGlobalRootCA.crt.pem
COPY Dockerfile-Extras/Exteranl-DB/DB.php /usr/src/rhymix/common/framework/DB.php

FROM amazonlinux:2023.6.20241010.0 AS final

ARG NGINX_VERSION=1.25.3
ARG PHP_VERSION=PHP8.29
ARG TARGETARCH

LABEL maintainer="NavyStack <webmaster@navystack.com>"
LABEL image_base="amazonlinux:2023.2.20231113.0"
LABEL rhymix_version="2.1.10"
LABEL root_ca="DigiCertGlobalRootCA"
LABEL arch="${TARGETARCH}"
LABEL php_version="${PHP_VERSION}"
LABEL nginx_version="${NGINX_VERSION}"
LABEL nginx_dy_modules="pagespeed, brotli, cache_purge, immutable"

RUN dnf -y install dnf-utils && \
    { \
		echo '[nginx-mainline]'; \
		echo 'name=nginx mainline repo'; \
		echo 'baseurl=http://nginx.org/packages/mainline/amzn/2023/$basearch/'; \
		echo 'gpgcheck=1'; \
		echo 'enabled=1'; \
		echo 'gpgkey=https://nginx.org/keys/nginx_signing.key'; \
		echo 'module_hotfixes=true'; \
		echo 'priority=9'; \        
	} > /etc/yum.repos.d/nginx.repo && \
    dnf config-manager --set-enabled nginx-mainline && \
    dnf -y install \
            php \
            nginx \
            #php-apcu \
            php-bcmath \
            php-cli \
            php-common \
            php-exif \
            php-fpm \
            php-gd \
            #php-imagick \
            php-intl \
            php-mbstring \
            php-mysqlnd \
            php-opcache \
            php-pdo \
            php-pear \
            #php-redis \
            php-soap \
            php-xml \
            #php-zip \
    && \
    dnf clean all && \
    dnf install -y \
        php-devel \
        gcc \
        libzip \
        libzip-devel \
        ImageMagick-devel \
        ImageMagick \
    && \
        pear update-channels && \
        pecl update-channels && \
    pecl install --configureoptions 'with-imagick="autodetect"' imagick && \
    pecl install -n \
            redis \
            apcu \
            zip \
    && \
        echo "extension=imagick.so" >> /etc/20-imagick.ini && \
        echo "extension=acpu.so" >> /etc/10-acpu.ini && \
        echo "extension=redis.so" >> /etc/10-redis.ini && \
        echo "extension=zip.so" >> /etc/20-zip.ini \
    && \
    { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
	} > /etc/php.d/opcache-recommended.ini \
    && \
    dnf -y remove \
        php-devel \
        gcc \
        libzip-devel \
        ImageMagick-devel \
    && \
        dnf clean all && \
        dnf autoremove && \
    dnf -y install ImageMagick && \
    dnf clean all \
    && \
        sed -i 's+^post_max_size = 8M+post_max_size = 120M+g;s+^upload_max_filesize = 2M+upload_max_filesize = 100M+g;s+^short_open_tag = Off+short_open_tag = On+g;s+;mysqli.allow_local_infile = On+mysqli.allow_local_infile = On+g' /etc/php.ini && \
        sed -i 's+pid = /run/php-fpm/php-fpm.pid+pid = /run/httpd/php-fpm.pid+g' /etc/php-fpm.conf && \
        sed -i 's+listen = /run/php-fpm/www.sock+listen = 9000+g' /etc/php-fpm.d/www.conf && \
        sed -i 's+user = apache+user = nginx+g' /etc/php-fpm.d/www.conf && \
        sed -i 's+group = apache+group = nginx+g' /etc/php-fpm.d/www.conf && \
        sed -i 's+SetHandler "proxy:unix:/run/php-fpm/www.sock|fcgi://localhost"+SetHandler "proxy:fcgi://127.0.0.1:9000"+g' /etc/httpd/conf.d/php.conf && \
    mkdir -p /var/run/ngx_pagespeed_cache && \
        chown -R nginx:nginx /var/run/ngx_pagespeed_cache && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

COPY --from=nginx-moduler /tmp/standby/nginx_modules/*.so /etc/nginx/modules/
COPY --from=nginx-moduler --chown=www-data:www-data /usr/src/rhymix /var/www/html
COPY Dockerfile-Extras/nginx-conf/nginx.conf /etc/nginx/nginx.conf 
COPY Dockerfile-Extras/nginx-conf/default.conf /etc/nginx/conf.d/default.conf

WORKDIR /var/www/html
VOLUME /var/www/html
EXPOSE 80

ENTRYPOINT ["/bin/sh", "-c", "/usr/sbin/php-fpm -D && nginx -g 'daemon off;'"]