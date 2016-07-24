FROM benyoo/centos-core:7.2.1511.20160706

MAINTAINER from www.dwhd.org by lookback (mondeolove@gmail.com)

ARG VERSION=${VERSION:-1.10.1}
ARG SHA256=${SHA256:-1fd35846566485e03c0e318989561c135c598323ff349c503a6c14826487a801}

ENV INSTALL_DIR=/usr/local/nginx \
	DATA_DIR=/data/wwwroot \
	TEMP_DIR=/tmp/nginx

RUN set -x && \
	mkdir -p ${TEMP_DIR} $(dirname ${DATA_DIR}) && cd ${TEMP_DIR} && \
	DOWN_URL="http://nginx.org/download" && \
	DOWN_URL="${DOWN_URL}/nginx-${VERSION}.tar.gz" && \
	FILE_NAME=${DOWN_URL##*/} && \
	useradd -r -m -d ${DATA_DIR} -k no -s /sbin/nologin -c 'WEB Server' www && \
	{ while :;do curl -Lk ${DOWN_URL} -o ${TEMP_DIR}/${FILE_NAME} && { [ "$(sha256sum ${TEMP_DIR}/${FILE_NAME}|awk '{print $1}')" == "${SHA256}" ] && break; }; done; } && \
	tar xf ${TEMP_DIR}/${FILE_NAME} && \
	echo -e '[base]\nname=Base\nmirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os&infra=$infra\n' > ${TEMP_DIR}/yum.conf && \
	echo -e '[updates]\nname=Updates \nmirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=updates&infra=$infra\n' >> ${TEMP_DIR}/yum.conf && \
	echo -e '[extras]\nname=Extras\nmirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras&infra=$infra\n' >> ${TEMP_DIR}/yum.conf && \
	echo -e '[centosplus]\nname=Plus\nmirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=centosplus&infra=$infra\n' >> ${TEMP_DIR}/yum.conf && \
	echo -e '[epel]\nname = EPEL\nmirrorlist = https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=$basearch\n' >> ${TEMP_DIR}/yum.conf && \
	echo -e '[rpmforge]\nname = RPMforge.net\nbaseurl=http://apt.sw.be/redhat/el7/en/$basearch/rpmforge\n' >> ${TEMP_DIR}/yum.conf && \
	rm -rf /etc/yum.repos.d/*.repo && \
	yum -c ${TEMP_DIR}/yum.conf install -y git openssl-devel zlib-devel gd-devel gcc make pcer GeoIP-devel GeoIP && \
	git clone https://github.com/cuber/ngx_http_google_filter_module.git && \
	git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git && \
	git clone https://github.com/aperezdc/ngx-fancyindex.git && \
	git clone https://github.com/openresty/echo-nginx-module.git && \
	cd ${FILE_NAME%%\.tar*} && \
	./configure --prefix=${INSTALL_DIR} \
		--user=www --group=www \
		--error-log-path=/var/log/wwwlogs/error.log \
		--http-log-path=/var/log/wwwlogs/access.log \
		--pid-path=/var/run/nginx/nginx.pid \
		--lock-path=/var/lock/nginx.lock \
		--with-pcre \
		--with-ipv6 \
		--with-http_ssl_module \
		--with-http_flv_module \
		--with-http_v2_module \
		--with-http_realip_module \
		--with-http_gzip_static_module \
		--with-http_stub_status_module \
		--with-http_mp4_module \
		--with-http_image_filter_module \
		--with-http_addition_module \
		--with-http_geoip_module \
		--http-client-body-temp-path=${INSTALL_DIR}/client/ \
		--http-proxy-temp-path=${INSTALL_DIR}/proxy/ \
		--http-fastcgi-temp-path=${INSTALL_DIR}/fcgi/ \
		--http-uwsgi-temp-path=${INSTALL_DIR}/uwsgi \
		--http-scgi-temp-path=${INSTALL_DIR}/scgi \
		--add-module=../ngx_http_google_filter_module \
		--add-module=../ngx_http_substitutions_filter_module \
		--add-module=../ngx-fancyindex \
		--add-module=../echo-nginx-module && \
	make -j $(awk '/processor/{i++}END{print i}' /proc/cpuinfo) && \
	make install && \
	yum -c ${TEMP_DIR}/yum.conf clean all && \
	rm -rf ${TEMP_DIR} /var/cache/{yum,ldconfig} && \
	mkdir -pv --mode=0755 /var/cache/{yum,ldconfig}

ENV PATH=${INSTALL_DIR}/sbin:$PATH

ADD nginx.conf ${INSTALL_DIR}/conf/nginx.conf
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["${DATA_DIR}"]
EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx"]
