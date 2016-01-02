#!/bin/sh
export KERNELDIR=`readlink -f .`
export PARENT_DIR=`readlink -f ..`
export ARCH=arm64
export SUBARCH=arm64
export PATH=/home/slim80/Scrivania/kernel/Compilatori/gcc-linaro-4.9-2014.11-x86_64_aarch64-elf/bin:$PATH
export CROSS_COMPILE=aarch64-none-elf-
export TARGET_PREBUILT_KERNEL=/home/slim80/Scrivania/kernel/LG/Imperium/Imperium_Kernel/arch/arm64/boot/Image.gz-dtb
export KCONFIG_NOTIMESTAMP=true

KERNELDIR="/home/slim80/Scrivania/kernel/LG/Imperium/Imperium_Kernel"
BUILDEDKERNEL="/home/slim80/Scrivania/kernel/LG/Imperium/Imperium_Kernel/1_Imperium"
IMAGE="/home/slim80/Scrivania/kernel/LG/Imperium/Imperium_Kernel/arch/arm64/boot"
RAMFS="/home/slim80/Scrivania/kernel/LG/Imperium/Imperium_ramdisk"
VERSION=1.0

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

make ARCH=arm64 imperium_defconfig || exit 1

make ARCH=arm64 CROSS_COMPILE=${CROSS_COMPILE} -j4 || exit 1

DTB=`find . -name "*.dtb" | head -1`echo $DTB
echo $DTB
DTBDIR=`dirname $DTB`
echo $DTBDIR
[[ -z `strings $DTB | grep "qcom,board-id"` ]] || DTBVERCMD="--force-v3"
echo $DTBVERCMD
./scripts/dtbtoolv3 $DTBVERCMD -o dt.img -s 4096 -p scripts/dtc/ $DTBDIR/

sh ./fix_ramfs_permissions.sh

./scripts/mkbootfs $RAMFS | gzip > ramdisk.gz 2>/dev/null

./scripts/mkbootimg --kernel $IMAGE/Image --ramdisk ramdisk.gz --base 0x00000000 --pagesize 4096 --kernel_offset 0x00008000 --ramdisk_offset 0x01000000 --tags_offset 00000100 --cmdline 'console=ttyHSL0,115200,n8 androidboot.console=ttyHSL0 user_debug=31 ehci-hcd.park=3 lpm_levels.sleep_disabled=1 androidboot.selinux=permissive msm_rtb.filter=0x37 boot_cpus=0-5 androidboot.hardware=p1' --dt dt.img -o $BUILDEDKERNEL/Builded_Kernel/boot.img

rm -rf imperium_install
mkdir -p imperium_install
make ARCH=arm64 CROSS_COMPILE=${CROSS_COMPILE} -j4 INSTALL_MOD_PATH=imperium_install INSTALL_MOD_STRIP=1 modules_install
find imperium_install/ -name '*.ko' -type f -exec cp '{}' $BUILDEDKERNEL/Builded_Kernel/system/lib/modules/ \;
cd $BUILDEDKERNEL/Builded_Kernel/
zip -r ../Imperium_Kernel_G4_v$VERSION.zip .

echo "* Done! *"
echo "* Imperium_Kernel_G4_Kernel_v1.0.zip is ready to be flashad *"
