FROM benyoo/alpine:3.7.20180123
MAINTAINER from www.dwhd.org by lookback (mondeolove@gmail.com)

ARG VERSION=${VERSION:-1.14.0}
#ARG SHA256=${SHA256:-1045ac4987a396e2fa5d0011daf8987b612dd2f05181b67507da68cbe7d765c2}
ARG AUTOINDEX_NAME_LEN=${AUTOINDEX_NAME_LEN:-100}

ENV INSTALL_DIR=/usr/local/nginx \
        DATA_DIR=/data/wwwroot \
        TEMP_DIR=/tmp/nginx


RUN set -x && \
        mkdir -p $(dirname ${DATA_DIR}) ${TEMP_DIR} && cd ${TEMP_DIR} && \
        DOWN_URL="http://nginx.org/download" && \
        DOWN_URL="${DOWN_URL}/nginx-${VERSION}.tar.gz" && \
        FILE_NAME=${DOWN_URL##*/} && mkdir -p ${TEMP_DIR}/${FILE_NAME%%\.tar*} && \
        apk --update --no-cache upgrade && \
        apk add --no-cache --virtual .build-deps geoip geoip-dev pcre libxslt gd openssl-dev pcre-dev zlib-dev \
                build-base linux-headers libxslt-dev gd-dev openssl-dev libstdc++ libgcc patch git tar curl luajit-dev=2.1.0_beta3-r0 && \
        curl -Lk ${DOWN_URL} | tar xz -C ${TEMP_DIR} --strip-components=1 && \
        git clone -b v0.6.4 https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git && \
        git clone -b v0.4.3 https://github.com/aperezdc/ngx-fancyindex.git && \
        git clone -b v0.3.1rc1 https://github.com/simplresty/ngx_devel_kit.git && \
        git clone -b v0.10.13 https://github.com/openresty/lua-nginx-module.git && \
        git clone -b v0.1.18 https://github.com/vozlt/nginx-module-vts.git && \
        git clone -b v0.3.0 https://github.com/yaoweibin/nginx_upstream_check_module.git && \
        git clone https://github.com/yzprofile/ngx_http_dyups_module.git && \
        git clone https://github.com/cfsego/ngx_log_if.git && \
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
        && \
        make -j$(getconf _NPROCESSORS_ONLN) && \
        make install && \
        runDeps="$( scanelf --needed --nobanner --recursive /usr/local/ | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' | sort -u | xargs -r apk info --installed | sort -u )" && \
        runDeps="${runDeps} inotify-tools supervisor logrotate python luajit-dev=2.1.0_beta3-r0" && \
        apk del .build-deps && \
        apk del build-base git patch && \
        apk add --no-cache --virtual .ngx-rundeps $runDeps && \
        rm -rf /var/cache/apk/* /tmp/* ${INSTALL_DIR}/conf/nginx.conf

ENV PATH=${INSTALL_DIR}/sbin:$PATH \
        TERM=linux

ADD etc /etc
ADD entrypoint.sh /entrypoint.sh

VOLUME ["${DATA_DIR}"]
EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]
