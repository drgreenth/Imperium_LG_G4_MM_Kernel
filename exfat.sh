#!/bin/sh
export KERNELDIR=`readlink -f .`
export PARENT_DIR=`readlink -f ..`
export ARCH=arm64
export SUBARCH=arm64
export PATH=/home/slim80/Scrivania/kernel/Compilatori/aarch64-linux-android-4.9/bin:$PATH
export CROSS_COMPILE=aarch64-linux-android-

IMPERIUM="/home/slim80/Scrivania/kernel/LG/Imperium"
KERNELDIR="/home/slim80/Scrivania/kernel/LG/Imperium/Imperium_Kernel"
BUILDEDKERNEL="/home/slim80/Scrivania/kernel/LG/Imperium/Imperium_Kernel/1_Imperium"

rm -f $BUILDEDKERNEL/Builded_Kernel/system/lib/modules/texfat.ko
cp -f tuxera_update.sh $IMPERIUM
mkdir -p $IMPERIUM/exfat/sign
mkdir -p $IMPERIUM/exfat/out/system/lib/modules
sh $IMPERIUM/tuxera_update.sh --target target/lg.d/mobile-msm8992-3.10.84 --use-cache --latest --max-cache-entries 2 --source-dir $IMPERIUM/Imperium_Kernel --output-dir $IMPERIUM/exfat/sign -a --user lg-mobile --pass AumlTsj0ou
tar -xzf tuxera-exfat*.tgz
cp tuxera-exfat*/exfat/kernel-module/texfat.ko $IMPERIUM/exfat/out/system/lib/modules/
cp tuxera-exfat*/exfat/tools/* $IMPERIUM/exfat/out/
perl ./scripts/sign-file sha1 $IMPERIUM/exfat/sign/signing_key.priv $IMPERIUM/exfat/sign/signing_key.x509 $IMPERIUM/exfat/out/system/lib/modules/texfat.ko
mv $IMPERIUM/out/system/lib/modules/texfat.ko $BUILDEDKERNEL/Builded_Kernel/system/lib/modules/
rm -f kheaders*.tar.bz2
rm -f tuxera-exfat*.tgz
rm -rf tuxera-exfat*
rm -rf .tuxera_update_cache
rm -rf $IMPERIUM/exfat/sign
rm -rf $IMPERIUM/exfat/out
rm -f $IMPERIUM/tuxera_update.sh

