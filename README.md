[![Docker Repository on Quay.io](https://quay.io/repository/benyoo/nginx/status "Docker Repository on Quay.io")](https://quay.io/repository/benyoo/nginx)[![](https://badge.imagelayers.io/sameersbn/gitlab.svg)](https://imagelayers.io/?images=benyoo/nginx:latest 'Get your own badge on imagelayers.io')

[![Deploy to Tutum](https://s.tutum.co/deploy-to-tutum.svg)](https://dashboard.tutum.co/stack/deploy/)

# 介绍

Dockerfile文件编译出一个[Nginx](http://www.nginx.org/) 容器镜像。

## 版本

当前版本: [benyoo/nginx:1.10.1](https://hub.docker.com/r/benyoo/nginx/)

# 帮助

如果你觉得这个镜像对你有用，你可以如下方法给我们提供帮助:

- 发送pull请求与你最新的功能和bug修复
- 帮助新用户解决他们可能遇到的[问题](https://github.com/xiaoyawl/docker-nginx/issues) 
- 对这个镜像的作者进行[捐助](支付宝:15555612612)

# 问题

如何安装Docker

```bash
curl -Lk https://get.docker.com/ | sh
```

RHEL、CentOS、Fedora的用户可以使用`setenforce 0`来禁用selinux以达到解决一些问题

如果你已经禁用了selinux并且使用的是最新版的Docker，如果还有疑问，你可以尝试通过 [issues](https://github.com/xiaoyawl/docker-nginx/issues) 页面来寻求帮助

当你在issue 提交问题的时候请注意提供一下信息:

- 宿主机的发行版和版本号.
- 使用 `docker version` 命令来给出Docker版本信息.
- 使用 `docker info` 命令来给出进一步信息.
- 提供 `docker run` 命令的详情 (注意打码你的隐私信息).

# 安装

直接使用我们在 [Dockerhub](https://hub.docker.com/r/benyoo/nginx) 上通过自动构建生成的镜像是最为推荐的方式

> **Note**: 也可以在 [Quay.io](https://quay.io/repository/benyoo/nginx)上构建

```bash
docker pull benyoo/nginx:latest
```

由于`1.10.1`版本的镜像已经打了tag。您也可以通过指定版本号的方式pull指定版本的镜像。 例如，

```bash
docker pull benyoo/nginx:1.10.1
```

另外你也可以通过自己构建来实现获取镜像。例如

```bash
docker build -t benyoo/nginx:1.10.1 github.com/xiaoyawl/docker-nginx
```

#运行
1、常规运行方法：
`docker run -d -p 80:80 -p 443:443 benyoo/nginx:latest
2、挂载数据目录方法：
```bash
docker run -d -p 80:80 -p 443:443 \
-v /etc/localtime:/etc/localtime:ro \ #将宿主机的时区文件挂载到容器内
-v /data/wwwroot:/data/wwwroot:rw \   #将宿主机的web文件挂载到容器内
-v /data/logs/wwwlogs:/data/wwwlogs:rw \  #将容器内的日志文件挂载到宿主机上
-v /data/conf/nginx/vhost:/usr/local/nginx/conf/vhost:rw \ #将配置文件挂载进容器
benyoo/nginx:latest
```
3、和php mysql redis 关联使用的方法
```bash
docker run -d --privileged --restart always \
--name redis_server -p 127.0.0.1:6379:6379 \
-v /etc/localtime:/etc/localtime:ro \
-v /etc/redis.conf:/etc/redis.conf:ro \
-v /data/redis:/data/redis:Z \
benyoo/redis
```
```bash
docker run -d --name mysql_server --restart always \
-p 3306:3306 -e MYSQL_ROOT_PASSWORD=lookback \
-v /etc/localtime:/etc/localtime:ro
-v /data/mariadb:/data/mariadb:rw
benyoo/mariadb
```
```bash
docker run -d --restart always --name php_server \
-e REDIS=Yes -e MEMCACHE=Yes -e SWOOLE=Yes \
--link redis_server:resid_server \
--link mysql_server:mysql_server \
-v /etc/localtime:/etc/localtime:ro
-v /data/wwwroot:/data/wwwroot:rw
benyoo/php
```
```bash
docker run -d --restart always --name nginx_server \
-p 80:80 -p 443:443 \
-e PHP_FPM=Yes -e PHP_FPM_SERVER=php_server \
-e PHP_FPM_PORT=9000 -e REWRITE=wordpress \
--link php_server:php_server \
--link mysql_server:mysql_server \
-v /etc/localtime:/etc/localtime:ro \
-v /data/wwwroot:/data/wwwroot:rw \
-v /data/logs/wwwlogs:/data/wwwlogs:rw \
-v /data/conf/nginx/vhost:/usr/local/nginx/conf/vhost:rw \
benyoo/nginx
```
