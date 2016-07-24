#!/bin/bash
#########################################################################
# File Name: entrypoint.sh
# Author: LookBack
# Email: admin#dwhd.org
# Version:
# Created Time: 2016年07月06日 星期三 18时51分33秒
#########################################################################

set -e

if [ -n "$TIMEZONE" ]; then
	rm -rf /etc/localtime && \
	ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime
fi

[ "${1:0:1}" = '-' ] && set -- nginx "$@"

sed -i "s@/home/wwwroot@$DATA_DIR@" ${INSTALL_DIR}/conf/nginx.conf
mkdir -p ${DATA_DIR}
[ ! -f "$DATA_DIR/index.html" ] && echo '<p>
<h1 style="text-align:center;">
	<span style="line-height:1.5;"><span style="color:#337FE5;">Hello world! This Nginx!</span><br />
	</span><span style="line-height:1.5;color:#E53333;">Welcome to use Docker!</span>
</h1>
<h1 style="text-align:center;">
	<span style="line-height:1.5;color:#E53333;">^_^┢┦aΡｐy&nbsp;</span>
</h1>
</p>
<p>
<br />
</p>
' > $DATA_DIR/index.html
chown -R www.www $DATA_DIR

CPU_num=$(awk '/processor/{i++}END{print i}' /proc/cpuinfo)
if [ "$CPU_num" == '2' ];then
	sed -i 's@^worker_processes.*@worker_processes 2;\nworker_cpu_affinity 10 01;@' ${INSTALL_DIR}/conf/nginx.conf
elif [ "$CPU_num" == '3' ];then
	sed -i 's@^worker_processes.*@worker_processes 3;\nworker_cpu_affinity 100 010 001;@' ${INSTALL_DIR}/conf/nginx.conf
elif [ "$CPU_num" == '4' ];then
	sed -i 's@^worker_processes.*@worker_processes 4;\nworker_cpu_affinity 1000 0100 0010 0001;@' ${INSTALL_DIR}/conf/nginx.conf
elif [ "$CPU_num" == '6' ];then
	sed -i 's@^worker_processes.*@worker_processes 6;\nworker_cpu_affinity 100000 010000 001000 000100 000010 000001;@' ${INSTALL_DIR}/conf/nginx.conf
elif [ "$CPU_num" == '8' ];then
	sed -i 's@^worker_processes.*@worker_processes 8;\nworker_cpu_affinity 10000000 01000000 00100000 00010000 00001000 00000100 00000010 00000001;@' ${INSTALL_DIR}/conf/nginx.conf
else
	echo Google worker_cpu_affinity
fi

exec "$@" -g "daemon off;"
