#!/bin/sh
export KERNELDIR=`readlink -f .`
export PARENT_DIR=`readlink -f ..`
export ARCH=arm64
export SUBARCH=arm64
export PATH=/home/slim80/Scrivania/kernel/Compilatori/aarch64-linux-android-4.9/bin:$PATH
export CROSS_COMPILE=aarch64-linux-android-
export TARGET_PREBUILT_KERNEL=/home/slim80/Scrivania/kernel/LG/Imperium/Imperium_Kernel/arch/arm64/boot/Image.gz-dtb
export KCONFIG_NOTIMESTAMP=true

KERNELDIR="/home/slim80/Scrivania/kernel/LG/Imperium/Imperium_Kernel"
BUILDEDKERNEL="/home/slim80/Scrivania/kernel/LG/Imperium/Imperium_Kernel/1_Imperium"
IMAGE="/home/slim80/Scrivania/kernel/LG/Imperium/Imperium_Kernel/arch/arm64/boot"

rm -f arch/arm64/boot/*.cmd
rm -f arch/arm64/boot/dts/*.cmd
rm -f arch/arm64/boot/Image*.*
rm -f arch/arm64/boot/.Image*.*
find -name '*.dtb' -exec rm -rf {} \;
find -name '*.ko' -exec rm -rf {} \;
rm -f $BUILDEDKERNEL/Builded_Kernel/boot.img
rm -f dt.img
rm -f ramdisk.gz

make clean
make distclean
ccache -C
