FROM benyoo/alpine:3.4.20160812
#FROM registry.ds.com/benyoo/alpine:3.4

MAINTAINER from www.dwhd.org by lookback (mondeolove@gmail.com)

ARG VERSION=${VERSION:-1.10.1}
ARG SHA256=${SHA256:-1fd35846566485e03c0e318989561c135c598323ff349c503a6c14826487a801}

ENV INSTALL_DIR=/usr/local/nginx \
	DATA_DIR=/data/wwwroot \
	TEMP_DIR=/tmp/nginx

RUN set -x && \
	mkdir -p $(dirname ${DATA_DIR}) ${TEMP_DIR} && cd ${TEMP_DIR} && \
	DOWN_URL="http://nginx.org/download" && \
	DOWN_URL="${DOWN_URL}/nginx-${VERSION}.tar.gz" && \
	FILE_NAME=${DOWN_URL##*/} && \
	apk --update --no-cache upgrade && \
		apk --update --no-cache add geoip pcre libxslt gd openssl-dev pcre-dev zlib-dev build-base git \
		geoip-dev linux-headers libxslt-dev gd-dev openssl-dev libstdc++ libgcc patch logrotate && \
	{ while :;do curl -LkO ${DOWN_URL} && { [ "$(sha256sum ${TEMP_DIR}/${FILE_NAME} | awk '{print $1}')" == "${SHA256}" ] && break; }; done; } && \
	tar xf ${TEMP_DIR}/${FILE_NAME} && \
	curl -Lk https://mirrors.dwhd.org/nginx-mode.tar.gz|tar xz -C ${TEMP_DIR} && \
	git clone https://github.com/arut/nginx-rtmp-module.git -b v1.1.7 && \
	git clone https://github.com/xiaokai-wang/nginx_upstream_check_module.git && \
	git clone https://github.com/xiaokai-wang/nginx-stream-upsync-module.git && \
	addgroup -g 400 -S www && \
	adduser -u 400 -S -h ${DATA_DIR} -s /sbin/nologin -g 'WEB Server' -G www www && \
	find ${TEMP_DIR} -type f -exec sed -i 's/\r$//g' {} \; && \
	cd ${FILE_NAME%%\.tar*} && \
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
	make -j $(awk '/processor/{i++}END{print i}' /proc/cpuinfo) && \
	make install && \
	apk del build-base git patch && \
	rm -rf /var/cache/apk/* /tmp/*

ENV PATH=${INSTALL_DIR}/sbin:$PATH \
	TERM=linux

ADD nginx.conf ${INSTALL_DIR}/conf/nginx.conf
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["${DATA_DIR}"]
EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx"]
