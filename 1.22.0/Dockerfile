FROM benyoo/alpine:3.16.20220908
MAINTAINER from www.dwhd.org by lookback (mondeolove@gmail.com)

ARG VERSION=${VERSION:-1.22.0}
#ARG SHA256=${SHA256:-1045ac4987a396e2fa5d0011daf8987b612dd2f05181b67507da68cbe7d765c2}
ARG AUTOINDEX_NAME_LEN=${AUTOINDEX_NAME_LEN:-100}

ENV INSTALL_DIR=/usr/local/nginx \
    DATA_DIR=/data/wwwroot \
    TEMP_DIR=/tmp/nginx


RUN set -x && \
    mkdir -p $(dirname ${DATA_DIR}) ${TEMP_DIR} && \
    apk update && \
    apk --update --no-cache upgrade && \
    apk add --no-cache --virtual .build-deps build-base gnupg pcre gd patch libxslt git tar curl \
        linux-headers libgcc libstdc++ \
        geoip-dev openssl-dev pcre-dev zlib-dev libc-dev \
		libxslt-dev gd-dev openssl-dev luajit-dev && \
    cd ${TEMP_DIR} && \
    DOWN_URL="http://nginx.org/download" && \
    DOWN_URL="${DOWN_URL}/nginx-${VERSION}.tar.gz" && \
    FILE_NAME=${DOWN_URL##*/} && mkdir -p ${TEMP_DIR}/${FILE_NAME%%\.tar*} && \
    curl -Lk ${DOWN_URL} | tar xz -C ${TEMP_DIR} --strip-components=1 && \
    git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git && \
    git clone https://github.com/aperezdc/ngx-fancyindex.git && \
    git clone https://github.com/simplresty/ngx_devel_kit.git && \
    git clone https://github.com/openresty/lua-nginx-module.git && \
    git clone https://github.com/vozlt/nginx-module-vts.git && \
    git clone https://github.com/yaoweibin/nginx_upstream_check_module.git && \
    git clone https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng.git && \
    git clone https://github.com/yzprofile/ngx_http_dyups_module.git && \
    git clone https://github.com/cfsego/ngx_log_if.git && \
    git clone https://github.com/openresty/headers-more-nginx-module.git && \
    git clone https://github.com/ipipdotnet/nginx-ipip-module.git && \
    patch -p1 < nginx_upstream_check_module/check_1.20.1+.patch && \
    addgroup -g 400 -S www && \
    adduser -u 400 -S -h ${DATA_DIR} -s /sbin/nologin -g 'WEB Server' -G www www && \
    export LUAJIT_LIB=/usr/lib && \
    export LUAJIT_INC=/usr/include/luajit-2.1 && \
    CFLAGS=-Wno-unused-but-set-variable ./configure --prefix=${INSTALL_DIR} \
        --user=www --group=www \
        --error-log-path=/data/wwwlogs/error.log \
        --http-log-path=/data/wwwlogs/access.log \
        --pid-path=/usr/local/nginx/nginx.pid \
        --lock-path=/var/lock/nginx.lock \
        --with-pcre \
        --with-ipv6 \
        --with-mail \
        --with-mail_ssl_module \
        --with-pcre-jit \
        --with-file-aio \
        --with-compat \
        --with-threads \
        --with-stream \
        --with-stream_ssl_module \
        --with-http_ssl_module \
        --with-http_flv_module \
        --with-http_v2_module \
        --with-http_realip_module \
        --with-http_gzip_static_module \
        --with-http_stub_status_module \
        --with-http_sub_module \
        --with-http_mp4_module \
        --with-http_image_filter_module \
        --with-http_addition_module \
        --with-http_auth_request_module \
        --with-http_dav_module \
        --with-http_degradation_module \
        --with-http_geoip_module \
        --with-http_xslt_module \
        --with-http_gunzip_module \
        --with-http_secure_link_module \
        --with-http_slice_module \
        --add-module=./ngx-fancyindex \
        --add-module=./ngx_http_substitutions_filter_module \
        --add-module=./ngx_devel_kit \
        --add-module=./lua-nginx-module \
        --add-module=./nginx-module-vts \
        --add-module=./nginx_upstream_check_module \
        --add-module=./ngx_log_if \
        --add-module=./ngx_http_dyups_module \
        --add-module=./headers-more-nginx-module \
        --add-dynamic-module=./nginx-ipip-module \
    && \
    make -j$(getconf _NPROCESSORS_ONLN) && \
    make install && \
    runDeps="$( scanelf --needed --nobanner --recursive /usr/local/ | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' | sort -u | xargs -r apk info --installed | sort -u )" && \
    runDeps="${runDeps} inotify-tools supervisor logrotate python3 luajit-dev" && \
    apk del .build-deps && \
    apk del build-base git patch && \
    apk add --no-cache --virtual .ngx-rundeps $runDeps && \
    rm -rf /var/cache/apk/* /tmp/* ${INSTALL_DIR}/conf/nginx.conf

ENV PATH=${INSTALL_DIR}/sbin:$PATH \
	TERM=linux

ADD etc /etc
RUN set -x && mv /etc/entrypoint.sh entrypoint.sh && chmod +x /entrypoint.sh

VOLUME ["${DATA_DIR}"]
EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]
