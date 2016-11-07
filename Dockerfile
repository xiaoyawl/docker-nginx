FROM benyoo/alpine:3.4.20160812
#FROM registry.ds.com/benyoo/alpine:3.4

MAINTAINER from www.dwhd.org by lookback (mondeolove@gmail.com)

ARG VERSION=${VERSION:-1.10.2}
ARG SHA256=${SHA256:-1045ac4987a396e2fa5d0011daf8987b612dd2f05181b67507da68cbe7d765c2}
ARG AUTOINDEX_NAME_LEN=${AUTOINDEX_NAME_LEN:-200}

ENV INSTALL_DIR=/usr/local/nginx \
	DATA_DIR=/data/wwwroot \
	TEMP_DIR=/tmp/nginx

RUN set -x && \
	LOCAL_MIRRORS=${LOCAL_MIRRORS:-http://mirrors.ds.com/alpine} && \
	NET_MIRRORS=${NET_MIRRORS:-http://dl-cdn.alpinelinux.org/alpine} && \
	LOCAL_MIRRORS_HTTP_CODE=$(curl -LI -m 10 -o /dev/null -sw %{http_code} ${LOCAL_MIRRORS}) && \
	if [ "${LOCAL_MIRRORS_HTTP_CODE}" == "200" ]; then \
		echo -e "${LOCAL_MIRRORS}/v3.4/main\n${LOCAL_MIRRORS}/v3.4/community" > /etc/apk/repositories; else \
		echo -e "${NET_MIRRORS}/v3.4/main\n${NET_MIRRORS}/v3.4/community" > /etc/apk/repositories; fi && \
	mkdir -p $(dirname ${DATA_DIR}) ${TEMP_DIR} && cd ${TEMP_DIR} && \
	DOWN_URL="http://nginx.org/download" && \
	DOWN_URL="${DOWN_URL}/nginx-${VERSION}.tar.gz" && \
	FILE_NAME=${DOWN_URL##*/} && mkdir -p ${TEMP_DIR}/${FILE_NAME%%\.tar*} && \
	apk --update --no-cache upgrade && \
		apk --update --no-cache add geoip geoip-dev pcre libxslt gd openssl-dev pcre-dev zlib-dev build-base \
		linux-headers libxslt-dev gd-dev openssl-dev libstdc++ libgcc patch logrotate supervisor inotify-tools git && \
	{ while :;do curl -LkO ${DOWN_URL} && { [ "$(sha256sum ${TEMP_DIR}/${FILE_NAME} | awk '{print $1}')" == "${SHA256}" ] && break; }; done; } && \
	tar xf ${TEMP_DIR}/${FILE_NAME} && \
	curl -Lk https://mirrors.dwhd.org/nginx-mode.tar.gz|tar xz -C ${TEMP_DIR} && \
	git clone https://github.com/arut/nginx-rtmp-module.git -b v1.1.7 && \
	git clone https://github.com/xiaokai-wang/nginx_upstream_check_module.git && \
	git clone https://github.com/xiaokai-wang/nginx-stream-upsync-module.git && \
	git clone https://github.com/leev/ngx_http_geoip2_module.git && \
	addgroup -g 400 -S www && \
	adduser -u 400 -S -h ${DATA_DIR} -s /sbin/nologin -g 'WEB Server' -G www www && \
	find ${TEMP_DIR} -type f -exec sed -i 's/\r$//g' {} \; && \
	cd ${FILE_NAME%%\.tar*} && \
	sed -ri "s/^(#define NGX_HTTP_AUTOINDEX_NAME_LEN).*/\1  ${AUTOINDEX_NAME_LEN}/" src/http/modules/ngx_http_autoindex_module.c && \
	sed -ri "s/^(#define NGX_HTTP_AUTOINDEX_PREALLOCATE).*/\1  ${AUTOINDEX_NAME_LEN}/" src/http/modules/ngx_http_autoindex_module.c && \
	patch -p0 < ../nginx_upstream_check_module/check_1.9.2+.patch && \
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
		--add-module=../ngx_http_substitutions_filter_module \
		--add-module=../ngx_fancyindex \
		--add-module=../echo_nginx_module \
		--add-module=../nginx-rtmp-module \
		--add-module=../nginx_upstream_check_module \
		--add-module=../nginx-stream-upsync-module && \
		--add-module=../ngx_http_geoip2_module && \
	make -j $(awk '/processor/{i++}END{print i}' /proc/cpuinfo) && \
	make install && \
	apk del build-base git patch && \
	rm -rf /var/cache/apk/* /tmp/* ${INSTALL_DIR}/conf/nginx.conf

ENV PATH=${INSTALL_DIR}/sbin:$PATH \
	TERM=linux

ADD etc /etc
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["${DATA_DIR}"]
EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]

#CMD ["/usr/sbin/supervisord"]
#CMD ["/bin/bash", "/entrypoint.sh"]
