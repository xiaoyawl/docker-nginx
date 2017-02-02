FROM benyoo/alpine:3.4.20160812
#FROM registry.ds.com/benyoo/alpine:3.4

MAINTAINER from www.dwhd.org by lookback (mondeolove@gmail.com)

ARG VERSION=${VERSION:-1.10.3}
#ARG SHA256=${SHA256:-1045ac4987a396e2fa5d0011daf8987b612dd2f05181b67507da68cbe7d765c2}
ARG AUTOINDEX_NAME_LEN=${AUTOINDEX_NAME_LEN:-100}

ENV INSTALL_DIR=/usr/local/nginx \
	DATA_DIR=/data/wwwroot \
	TEMP_DIR=/tmp/nginx

RUN set -x && \
	mkdir -p $(dirname ${DATA_DIR}) ${TEMP_DIR}/LuaJIT && \
	DOWN_URL="http://nginx.org/download" && \
	DOWN_URL="${DOWN_URL}/nginx-${VERSION}.tar.gz" && \
	FILE_NAME=${DOWN_URL##*/} && mkdir -p ${TEMP_DIR}/${FILE_NAME%%\.tar*} && \
	apk --update --no-cache upgrade && \
	apk add --no-cache --virtual .build-deps geoip geoip-dev pcre libxslt gd openssl-dev pcre-dev zlib-dev \
		build-base linux-headers libxslt-dev gd-dev openssl-dev libstdc++ libgcc patch git tar curl && \
#Install LuaJIT
	curl -Lk "http://luajit.org/download/LuaJIT-2.1.0-beta2.tar.gz"| tar -xz -C ${TEMP_DIR}/LuaJIT --strip-components=1 && \
	cd ${TEMP_DIR}/LuaJIT && \
	make -j$(getconf _NPROCESSORS_ONLN) PREFIX=/usr/local/luajit && \
	make install PREFIX=/usr/local/luajit && \
	#ln -s /usr/local/luajit/lib/libluajit-5.1.so.2 /lib/libluajit-5.1.so.2 && \
	ln -s /usr/local/luajit/lib/libluajit-5.1.so.2.1.0 /lib/libluajit-5.1.so.2 && \
	export LUAJIT_LIB=/usr/local/luajit/lib && \
	export LUAJIT_INC=/usr/local/luajit/include/luajit-2.1 && \
#Install Nginx
	cd ${TEMP_DIR} && \
	curl -Lk ${DOWN_URL} | tar xz -C ${TEMP_DIR} --strip-components=1 && \
	curl -Lk https://github.com/xiaoyawl/centos_init/raw/master/nginx-mode.tar.gz|tar xz -C ${TEMP_DIR} && \
	git clone https://github.com/arut/nginx-rtmp-module.git -b v1.1.7 && \
	git clone https://github.com/xiaokai-wang/nginx_upstream_check_module.git && \
	git clone https://github.com/xiaokai-wang/nginx-stream-upsync-module.git && \
	git clone https://github.com/simpl/ngx_devel_kit.git && \
	git clone https://github.com/openresty/lua-nginx-module.git && \
	git clone https://github.com/calio/form-input-nginx-module.git && \
	#git clone https://github.com/leev/ngx_http_geoip2_module.git && \
	addgroup -g 400 -S www && \
	adduser -u 400 -S -h ${DATA_DIR} -s /sbin/nologin -g 'WEB Server' -G www www && \
	find ${TEMP_DIR} -type f -exec sed -i 's/\r$//g' {} \; && \
	#cd ${FILE_NAME%%\.tar*} && \
	sed -ri "s/^(#define NGX_HTTP_AUTOINDEX_NAME_LEN).*/\1  ${AUTOINDEX_NAME_LEN}/" src/http/modules/ngx_http_autoindex_module.c && \
	sed -ri "s/^(#define NGX_HTTP_AUTOINDEX_PREALLOCATE).*/\1  ${AUTOINDEX_NAME_LEN}/" src/http/modules/ngx_http_autoindex_module.c && \
	patch -p0 < ./nginx_upstream_check_module/check_1.9.2+.patch && \
#Build Nginx
	CFLAGS=-Wno-unused-but-set-variable ./configure --prefix=${INSTALL_DIR} \
		--user=www --group=www \
		--error-log-path=/data/wwwlogs/error.log \
		--http-log-path=/data/wwwlogs/access.log \
		--pid-path=/var/run/nginx/nginx.pid \
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
		--http-client-body-temp-path=${INSTALL_DIR}/client/ \
		--http-proxy-temp-path=${INSTALL_DIR}/proxy/ \
		--http-fastcgi-temp-path=${INSTALL_DIR}/fcgi/ \
		--http-uwsgi-temp-path=${INSTALL_DIR}/uwsgi \
		--http-scgi-temp-path=${INSTALL_DIR}/scgi \
		--with-ld-opt="-Wl,-rpath,/usr/local/luajit/lib" \
		--add-module=./ngx_devel_kit \
		--add-module=./lua-nginx-module \
		--add-module=./form-input-nginx-module \
		--add-module=./ngx_http_substitutions_filter_module \
		--add-module=./ngx_fancyindex \
		--add-module=./echo_nginx_module \
		--add-module=./nginx-rtmp-module \
		--add-module=./nginx_upstream_check_module \
		--add-module=./nginx-stream-upsync-module && \
		#--add-module=./ngx_http_geoip2_module && \
	make -j$(getconf _NPROCESSORS_ONLN) && \
	make install && \
	runDeps="$( scanelf --needed --nobanner --recursive /usr/local | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' | sort -u | xargs -r apk info --installed | sort -u )" && \
	runDeps="${runDeps} inotify-tools supervisor logrotate python" && \
	apk add --no-cache --virtual .ngx-rundeps $runDeps && \
	apk del .build-deps && \
	#apk del build-base git patch && \
	rm -rf /var/cache/apk/* /tmp/* ${INSTALL_DIR}/conf/nginx.conf

ENV PATH=${INSTALL_DIR}/sbin:$PATH \
	TERM=linux

ADD etc /etc
ADD entrypoint.sh /entrypoint.sh

VOLUME ["${DATA_DIR}"]
EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]

#CMD ["/usr/sbin/supervisord"]
#CMD ["/bin/bash", "/entrypoint.sh"]
