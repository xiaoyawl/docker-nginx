#!/bin/bash
#########################################################################
# File Name: entrypoint.sh
# Author: LookBack
# Email: admin#dwhd.org
# Version:
# Created Time: 2016年08月12日 星期五 16时43分50秒
#########################################################################

set -e
[[ $DEBUG == true ]] && set -x
SED_CHANGE=${SED_CHANGE:-enable}

if [ -n "$TIMEZONE" ]; then
	rm -rf /etc/localtime && \
	ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime
fi

Nginx_Conf_Dir=/etc/nginx-conf-example
[ ! -d /var/log/supervisor ] && mkdir -p /var/log/supervisor
#[ "${1:0:1}" = '-' ] && set -- nginx "$@"

mkdir -p ${DATA_DIR}
[ ! -f "$DATA_DIR/index.html" ] && echo 'Hello here, Let us see the world.' > $DATA_DIR/index.html

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

#if [ ! -f ${INSTALL_DIR}/conf/nginx.conf ]; then
if [[ ! "${SED_CHANGE}" =~ ^[eE][nN][aA][bB][lL][eE]$ ]]; then
	chown -R www.www $DATA_DIR
	cp ${Nginx_Conf_Dir}/nginx.conf ${INSTALL_DIR}/conf/nginx.conf
	sed -i "s@/home/wwwroot@$DATA_DIR@" ${INSTALL_DIR}/conf/nginx.conf
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
fi

if [ -n "$REWRITE" ]; then
	[ ! -d ${INSTALL_DIR}/conf/rewrite ] && mkdir -p ${INSTALL_DIR}/conf/rewrite
	if [ "$REWRITE" = "wordpress" ]; then
		[ ! -f ${INSTALL_DIR}/conf/rewrite/wordpress.conf ] && cp ${Nginx_Conf_Dir}/rewrite/wordpress.conf ${INSTALL_DIR}/conf/rewrite/wordpress.conf
	elif [ "$REWRITE" = "discuz" ]; then
		[ ! -f ${INSTALL_DIR}/conf/rewrite/discuz.conf ] && cp ${Nginx_Conf_Dir}/rewrite/discuz.conf ${INSTALL_DIR}/conf/rewrite/discuz.conf
	elif [ "$REWRITE" = "opencart" ]; then
		[ ! -f ${INSTALL_DIR}/conf/rewrite/opencart.conf ] && cp ${Nginx_Conf_Dir}/rewrite/opencart.conf ${INSTALL_DIR}/conf/rewrite/opencart.conf
	elif [ "$REWRITE" = "laravel" ]; then
		[ ! -f ${INSTALL_DIR}/conf/rewrite/opencart.conf ] && cp ${Nginx_Conf_Dir}/rewrite/opencart.conf ${INSTALL_DIR}/conf/rewrite/opencart.conf
	elif [ ! -f "$REWRITE" = "typecho" ]; then
		[ ! -f ${INSTALL_DIR}/conf/rewrite/typecho.conf ] && cp ${Nginx_Conf_Dir}/rewrite/typecho.conf ${INSTALL_DIR}/conf/rewrite/typecho.conf
	elif [ ! -f "$REWRITE" = "ecshop" ]; then
		[ ! -f ${INSTALL_DIR}/conf/rewrite/ecshop.conf ] && cp ${Nginx_Conf_Dir}/rewrite/ecshop.conf ${INSTALL_DIR}/conf/rewrite/ecshop.conf
	elif [ ! -f "$REWRITE" = "drupal" ]; then
		[ ! -f ${INSTALL_DIR}/conf/rewrite/drupal.conf ] && cp ${Nginx_Conf_Dir}/rewrite/drupal.conf ${INSTALL_DIR}/conf/rewrite/drupal.conf
	elif [ ! -f "$REWRITE" = "joomla" ]; then
		[ ! -f ${INSTALL_DIR}/conf/rewrite/joomla.conf ] && cp ${Nginx_Conf_Dir}/rewrite/joomla.conf ${INSTALL_DIR}/conf/rewrite/joomla.conf
	fi
fi

if [[ -n ${SUPERVISOR_PORT} ]]; then
	sed -i "s/^port.*/port = 0.0.0.0:${SUPERVISOR_PORT}/" /etc/supervisord.conf
fi

supervisord -n -c /etc/supervisord.conf
