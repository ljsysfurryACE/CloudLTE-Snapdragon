#!/bin/bash
# CloudLTE-Snapdragon 交叉编译脚本 (骁龙 410 / MSM8916)
set -e

ARCH=arm64
CROSS=aarch64-linux-gnu-
KERNEL_VER=5.4.269
KERNEL_URL="https://mirrors.tuna.tsinghua.edu.cn/kernel/v5.x/linux-${KERNEL_VER}.tar.xz"
DIR=/tmp/cloudlte-snap-build
OUT=$DIR/output

echo "=== ☁️ CloudLTE-Snapdragon Build ==="
mkdir -p $DIR $OUT

# 1. 工具链
echo "[1/4] 检查交叉编译工具链..."
command -v ${CROSS}gcc >/dev/null || { echo "装: apt install gcc-aarch64-linux-gnu"; exit 1; }
${CROSS}gcc --version | head -1

# 2. 内核 (高通 MSM8916)
echo "[2/4] 内核 Linux $KERNEL_VER (MSM8916)..."
cd $DIR
[ -f linux-${KERNEL_VER}.tar.xz ] || curl -L -o linux-${KERNEL_VER}.tar.xz $KERNEL_URL
[ -d linux-${KERNEL_VER} ] || tar xf linux-${KERNEL_VER}.tar.xz
cd linux-${KERNEL_VER}
make ARCH=$ARCH CROSS_COMPILE=$CROSS defconfig
# CONFIG_ARCH_QCOM=y 已在 arm64 defconfig 里
make ARCH=$ARCH CROSS_COMPILE=$CROSS -j4 Image dtbs 2>&1 | tail -3
cp arch/arm64/boot/Image $OUT/
cp arch/arm64/boot/dts/qcom/msm8916-mtp.dtb $OUT/

# 3. initramfs (BusyBox 复用 CloudLTE-ARM64 构建产物或重新编)
echo "[3/4] initramfs..."
rm -rf $DIR/initramfs && mkdir -p $DIR/initramfs/{bin,dev,proc,sys,etc,mnt,root}
if [ -f /tmp/busybox-1.36.1/busybox ]; then
    cp /tmp/busybox-1.36.1/busybox $DIR/initramfs/bin/
else
    echo "  需要先编译 BusyBox (见 README)"
    exit 1
fi
cd $DIR/initramfs/bin
for app in sh ls cat mount umount ps echo mkdir cp mv rm dmesg reboot poweroff; do
    ln -sf busybox $app
done
cat > $DIR/initramfs/init << 'EOF'
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev
echo ''
echo '===================='
echo ' CloudLTE-Snapdragon'
echo ' (Linux 5.4 MSM8916)'
echo '===================='
echo 'Booting... init OK'
echo ''
exec /bin/sh
EOF
chmod +x $DIR/initramfs/init
cd $DIR/initramfs && find . | cpio -o -H newc 2>/dev/null | gzip > $OUT/initramfs.gz

# 4. 汇总
echo "[4/4] 输出:"
ls -lh $OUT/
echo ""
echo "=== ✅ CloudLTE-Snapdragon 构建完成 ==="
echo "QEMU 验证:"
echo "  qemu-system-aarch64 -M virt -cpu cortex-a53 -m 512 -kernel $OUT/Image -initrd $OUT/initramfs.gz -append 'console=ttyAMA0 rdinit=/init panic=-1' -nographic"
