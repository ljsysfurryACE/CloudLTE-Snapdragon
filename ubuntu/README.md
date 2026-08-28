# ☁️ CloudLTE-Snapdragon Ubuntu 版 (v2.0)

基于 **Ubuntu 24.04 base** 的骁龙 410 系统，带 **apt 包管理器**。

## 与轻量版 (v1.1) 的区别

| | 轻量版 v1.1 | Ubuntu 版 v2.0 |
|--|-----------|---------------|
| 基础 | BusyBox (1.8MB) | **Ubuntu base (351MB)** |
| 包管理 | 无 | **apt/dpkg** ✅ |
| SSH | dropbear | **openssh-server** |
| Web | busybox httpd | **nginx** |
| 可扩展性 | 极简 | **apt install 随便装** |
| RAM 占用 | ~8MB | ~200MB |

## 内容

- Ubuntu 24.04 arm64 base (debootstrap minbase)
- openssh-server (root/cloudlte)
- nginx (聊天 UI 在 /var/www/html)
- 聊天 WebUI: 浏览器直连 DeepSeek API

## 使用

```bash
# 解包 rootfs
mkdir rootfs && tar xzf cloudlte_ubuntu_rootfs.tar.gz -C rootfs
# 挂载 + chroot
mount --bind /dev rootfs/dev
mount --bind /proc rootfs/proc
mount --bind /sys rootfs/sys
chroot rootfs /bin/bash
# 启动服务
service ssh start
service nginx start
```

## 许可证

- 本系统部分: GPL-3.0 © Cloud LTE Studio
- Ubuntu base 组件 (GPL-2.0): apt/dpkg 等源码见
  - https://launchpad.net/ubuntu/+source/apt
  - https://launchpad.net/ubuntu/+source/dpkg

## 构建

```bash
debootstrap --arch=arm64 --variant=minbase noble rootfs http://ports.ubuntu.com/ubuntu-ports
chroot rootfs apt-get install -y openssh-server nginx
```
