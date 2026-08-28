# ☁️ CloudLTE-Snapdragon Ubuntu 26.04 版 (v2.1)

基于 **Ubuntu 26.04 LTS (resolute)** base 的骁龙 410 系统，带 **apt 包管理器**。

## 与 v2.0 (24.04) 的区别

| | v2.0 (24.04 noble) | v2.1 (26.04 resolute) |
|--|-------------------|---------------------|
| Ubuntu 版本 | 24.04 LTS | **26.04 LTS** ✅ |
| 大小 | 83MB tar | **77MB tar** (更紧凑) |
| 支持周期 | 2029 | **2031** |

## 内容

- Ubuntu 26.04 arm64 base (debootstrap minbase)
- openssh-server (root/cloudlte)
- nginx (聊天 UI 在 /var/www/html)
- 聊天 WebUI: 浏览器直连 DeepSeek API

## 使用

```bash
mkdir rootfs && tar xzf cloudlte_ubuntu26_rootfs.tar.gz -C rootfs
mount --bind /dev rootfs/dev
mount --bind /proc rootfs/proc
mount --bind /sys rootfs/sys
chroot rootfs /bin/bash
service ssh start
service nginx start
```

## 许可证

- 本系统部分: GPL-3.0 © Cloud LTE Studio
- Ubuntu base (GPL-2.0): apt/dpkg 源码见
  - https://launchpad.net/ubuntu/+source/apt
  - https://launchpad.net/ubuntu/+source/dpkg

## 构建

```bash
debootstrap --arch=arm64 --variant=minbase resolute rootfs http://ports.ubuntu.com/ubuntu-ports
chroot rootfs apt-get install -y openssh-server nginx
```

## 下载 rootfs

rootfs (77MB) 通过 GitHub Releases 分发:
https://github.com/ljsysfurryACE/CloudLTE-Snapdragon/releases/tag/v2.1
文件: `cloudlte_ubuntu26_rootfs.tar.gz`
