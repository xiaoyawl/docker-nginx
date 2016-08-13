#!/bin/bash
#########################################################################
# File Name: entrypoint.sh
# Author: LookBack
# Email: admin#dwhd.org
# Version:
# Created Time: 2016年08月12日 星期五 16时43分50秒
#########################################################################

set -e

if [ -n "$TIMEZONE" ]; then
	rm -rf /etc/localtime && \
	ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime
fi

[ "${1:0:1}" = '-' ] && set -- nginx "$@"

sed -i "s@/home/wwwroot@$DATA_DIR@" ${INSTALL_DIR}/conf/nginx.conf
mkdir -p ${DATA_DIR}
[ ! -f "$DATA_DIR/index.html" ] && echo 'Hello here, Let us see the world.' > $DATA_DIR/index.html
chown -R www.www $DATA_DIR

if [ -d /etc/logrotate.d ]; then
	cat > /etc/logrotate.d/nginx <<-EOF
		$(dirname ${DATA_DIR})/wwwlogs/*.log {
			daily
			rotate 5
			missingok
			dateext
			compress
			notifempty
			sharedscripts
			postrotate
    		[ -e /var/run/nginx.pid ] && kill -USR1 \`cat /var/run/nginx.pid\`
			endscript
		}
	EOF
fi

if [[ "${PHP_FPM}" =~ ^[yY][eS][sS]$ ]]; then
	if [ -z "${PHP_FPM_SERVER}" ]; then
		echo >&2 'error:  missing PHP_FPM_SERVER'
		echo >&2 '  Did you forget to add -e PHP_FPM_SERVER=... ?'
		exit 127
	fi
	PHP_FPM_PORT=${PHP_FPM_PORT:-9000}
	sed -i "s/PHP_FPM_SERVER/${PHP_FPM_SERVER}/" ${INSTALL_DIR}/conf/nginx.conf
	sed -i "s/PORT/${PHP_FPM_PORT}/" ${INSTALL_DIR}/conf/nginx.conf
	[ -f ${DATA_DIR}/index.php ] || cat > ${DATA_DIR}/index.php <<< '<? phpinfo(); ?>'
else
	sed -i '73,78d' ${INSTALL_DIR}/conf/nginx.conf
fi

exec "$@" -g "daemon off;"
