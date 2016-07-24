[![Docker Repository on Quay.io](https://quay.io/repository/benyoo/nginx/status "Docker Repository on Quay.io")](https://quay.io/repository/benyoo/nginx)[![](https://badge.imagelayers.io/sameersbn/gitlab.svg)](https://imagelayers.io/?images=benyoo/nginx:latest 'Get your own badge on imagelayers.io')

[![Deploy to Tutum](https://s.tutum.co/deploy-to-tutum.svg)](https://dashboard.tutum.co/stack/deploy/)

# Introduction

Dockerfile to build a [Nginx](http://www.nginx.org/) container image.

## Version

Current Version: **benyoo/nginx:1.10.1**

# Contributing

If you find this image useful here's how you can help:

- Send a Pull Request with your awesome new features and bug fixes
- Help new users with [Issues](https://github.com/xiaoyawl/nginx-docker/issues) they may encounter
- Support the development of this image with a [donation](支付宝:15555612612)

# Issues

Docker is a relatively new project and is active being developed and tested by a thriving community of developers and testers and every
release of docker features many enhancements and bugfixes.

Given the nature of the development and release cycle it is very important that you have the latest version of docker installed because
any issue that you encounter might have already been fixed with a newer docker release.

Install the most recent version of the Docker Engine for your platform using the [official Docker releases](http://docs.docker.com/engin
e/installation/), which can also be installed using:

```bash
curl -Lk https://get.docker.com/ | sh
```

Fedora and RHEL/CentOS users should try disabling selinux with `setenforce 0` and check if resolves the issue. If it does than there is
not much that I can help you with. You can either stick with selinux disabled (not recommended by redhat) or switch to using ubuntu.

If using the latest docker version and/or disabling selinux does not fix the issue then please file a issue request on the [issues](http
s://github.com/xiaoyawl/nginx-docker/issues) page.

In your issue report please make sure you provide the following information:

- The host distribution and release version.
- Output of the `docker version` command.
- Output of the `docker info` command.
- The `docker run` command you used to run the image (mask out the sensitive bits).

# Installation

Automated builds of the image are available on [Dockerhub](https://hub.docker.com/r/benyoo/nginx) and is the recommended method of
installation.

> **Note**: Builds are also available on [Quay.io](https://quay.io/repository/benyoo/nginx)

```bash
docker pull benyoo/nginx:latest
```

Since version `1.10.0`, the image builds are being tagged. You can now pull a particular version of redmine by specifying the version num
ber. For example,

```bash
docker pull benyoo/nginx:1.10.1
```

Alternately you can build the image yourself.

```bash
docker build -t benyoo/nginx:1.10.1 github.com/xiaoyawl/nginx-docker
```
