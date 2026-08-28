# ☁️ CloudLTE-Snapdragon

**Cloud LTE OS 的骁龙 410 (MSM8916) 移植版** — Linux from Scratch 极简系统。

面向 **19.9 元的骁龙 410 无线 WiFi 设备**（16MB RAM / 512MB 存储），定位**内网 AI 聊天终端**（浏览器直连 DeepSeek API）。

## ✨ 特性

| 特性 | 说明 |
|------|------|
| 🧠 内核 | Linux **5.4.269** (ARM64, 高通 MSM8916) |
| 📦 体积 | 内核 26MB + initramfs 1.2MB |
| ⚡ Shell | BusyBox 1.36.1 (ARM64 静态) |
| 🔋 内存 | 目标设备 16MB RAM 可跑（全系统 ~8MB）|
| 💬 用途 | 内网 AI 聊天 WebUI（静态页 + JS 直连 DeepSeek）|
| 🧩 SoC | 骁龙 410 (MSM8916, 4×Cortex-A53) |

## 📦 文件

| 文件 | 大小 | 说明 |
|------|------|------|
| `Image` | 26MB | Linux 5.4.269 ARM64 内核 (MSM8916) |
| `msm8916-mtp.dtb` | 38K | 骁龙 410 设备树 (MTP 参考板) |
| `initramfs.gz` | 1.2MB | 最小 rootfs (BusyBox + init) |
| `busybox` | 2.1MB | ARM64 静态 BusyBox |
| `build.sh` | — | 高通内核交叉编译脚本 |

## 🚀 QEMU 启动验证（实测通过）

```bash
qemu-system-aarch64 -M virt -cpu cortex-a53 -m 512 \
  -kernel Image \
  -initrd initramfs.gz \
  -append 'console=ttyAMA0 rdinit=/init panic=-1' \
  -nographic
```

**实测输出**:

```
Booting Linux on physical CPU
Run /init as init process
 Cloud LTE OS ARM64
Booting... init OK
~ #                    ← BusyBox shell
```

## 🔨 交叉编译（高通内核）

```bash
# 工具链
apt install gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu

# 内核 5.4.269 (5.4 主线支持 MSM8916)
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig
# CONFIG_ARCH_QCOM 已在 defconfig 中启用
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4 Image dtbs

# BusyBox (复用 CloudLTE-ARM64 的)
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig
sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j4
```

## ⚠️ 踩坑记录

1. **增量编译陷阱**: 换了 .config 后必须 `make clean` 再编，否则 make 认为 Image 已新不重编
2. **nohup 陷阱**: ssh 会话结束会带走后台进程, 用 `setsid bash -c '...' < /dev/null &`
3. **MSM8916 设备树**: 5.4 主线自带 `arch/arm64/boot/dts/qcom/msm8916*.dtsi`
4. **16MB RAM 设备**: 全系统 ~8MB (内核 6MB + httpd 1MB + 页面 0.5MB)

## 🎯 Roadmap

- [x] MSM8916 内核 + BusyBox + initramfs 启动链
- [x] QEMU 启动验证 (shell 可用)
- [ ] 聊天 WebUI (静态页 + JS 直连 DeepSeek)
- [ ] 真实设备刷机 (fastboot/boot.img)
- [ ] WiFi 驱动 (wcnss)

## 许可证

GPL-3.0 © Cloud LTE Studio

## v1.1 — SSH + 聊天 WebUI 完整版

新增:
- **Dropbear SSH** (ARM64 静态, 22 端口, 密钥认证)
- **聊天 WebUI** (web/index.html, 浏览器直连 DeepSeek API)
- 完整 initramfs: `snap_initramfs_ssh.gz` (1.8MB, 含 SSH+Web+聊天)
- init 自动启动 SSH + Web 服务

使用:
1. 刷入系统 → 开机
2. 浏览器访问 http://设备IP → 点 ⚙️ 配置 DeepSeek Key
3. SSH: ssh root@设备IP (密钥认证)

文件: `snap_initramfs_ssh.gz` (完整系统) / `dropbear_arm64` (SSH 二进制) / `init_full` (启动脚本)
