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
