#!/sbin/busybox sh

BB=/sbin/busybox

# Mounting partition in RW mode

OPEN_RW()
{
        $BB mount -o remount,rw /;
        $BB mount -o remount,rw /system;
}
OPEN_RW;

# Installing Busybox
CLEAN_BUSYBOX()
{
	for f in *; do
		case "$($BB readlink "$f")" in *usybox*)
			$BB rm "$f"
		;;
		esac
	done;
}

# Cleanup the old busybox symlinks
cd /system/xbin/;
CLEAN_BUSYBOX;

cd /system/bin/;
CLEAN_BUSYBOX;

cd /;

# Install latest busybox to ROM
$BB cp /sbin/busybox /system/xbin/;

/system/xbin/busybox --install -s /system/xbin/
if [ -e /system/xbin/wget ]; then
	rm /system/xbin/wget;
fi;
if [ -e /system/wget/wget ]; then
	chmod 755 /system/wget/wget;
	ln -s /system/wget/wget /system/xbin/wget;
fi;
chmod 06755 /system/xbin/busybox;
if [ -e /system/xbin/su ]; then
	$BB chmod 06755 /system/xbin/su;
fi;
if [ -e /system/xbin/daemonsu ]; then
	$BB chmod 06755 /system/xbin/daemonsu;
fi;

# Fixing ROOT
/system/xbin/daemonsu --auto-daemon &

# Create init.d folder if missing
if [ ! -d /system/etc/init.d ]; then
	$BB mkdir -p /system/etc/init.d/
	$BB chmod -R 755 /system/etc/init.d/
fi

# Start script in init.d folder
$BB run-parts /system/etc/init.d/

sleep 1;

# Run Qualcomm scripts in system/etc folder if exists
if [ -f /system/etc/init.qcom.post_boot.sh ]; then
	$BB chmod 755 /system/etc/init.qcom.post_boot.sh;
	$BB sh /system/etc/init.qcom.post_boot.sh;
fi;

sleep 1;

OPEN_RW;

# Cleaning
$BB rm -rf /cache/lost+found/* 2> /dev/null;
$BB rm -rf /data/lost+found/* 2> /dev/null;
$BB rm -rf /data/tombstones/* 2> /dev/null;

OPEN_RW;

CRITICAL_PERM_FIX()
{
	# critical Permissions fix
	$BB chown -R system:system /data/anr;
	$BB chown -R root:root /data/property;
	$BB chown -R root:root /tmp;
	$BB chown -R root:root /res;
	$BB chown -R root:root /sbin;
	$BB chown -R root:root /lib;
	$BB chmod -R 777 /tmp/;
	$BB chmod -R 775 /res/;
	$BB chmod -R 0775 /data/anr/;
	$BB chmod -R 0700 /data/property;
	$BB chmod -R 0771 /data/tombstones;
}
CRITICAL_PERM_FIX;

# Prop tweaks
setprop persist.adb.notify 0
setprop persist.service.adb.enable 1
setprop pm.sleep_mode 1
setprop logcat.live disable
setprop profiler.force_disable_ulog 1
setprop ro.ril.disable.power.collapse 0
setprop persist.service.btui.use_aptx 1

# Fix critical perms again after init.d mess
	CRITICAL_PERM_FIX;
	
sleep 2;

# script finish here, so let me know when
rm /data/local/tmp/Imperium_LL_Kernel
touch /data/local/tmp/Imperium_LL_Kernel
echo "Imperium LL Kernel script correctly applied" > /data/local/tmp/Imperium_LL_Kernel;

$BB mount -t rootfs -o remount,ro rootfs
$BB mount -o remount,ro /system

