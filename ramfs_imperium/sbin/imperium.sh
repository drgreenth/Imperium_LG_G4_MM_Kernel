#!/system/bin/sh

BB=/sbin/busybox

$BB mount -t rootfs -o remount,rw rootfs

sync

# Installing Busybox
$BB chmod 06755 /system/xbin/busybox
./system/xbin/busybox --install -s /system/xbin/

# Fixing su permissions
if [ -e /system/xbin/su ]; then
	$BB chmod 06755 /system/xbin/su;
fi;
if [ -e /system/xbin/daemonsu ]; then
	$BB chmod 06755 /system/xbin/daemonsu;
fi;

# Fixing ROOT
/system/xbin/daemonsu --auto-daemon &

# Creating init.d folder if missing
if [ ! -e /system/etc/init.d ]; then
	mkdir /system/etc/init.d
	chown -R root.root /system/etc/init.d
	chmod -R 755 /system/etc/init.d
fi;

# Start script in init.d folder
$BB run-parts /system/etc/init.d/

# Cleaning
$BB rm -rf /cache/lost+found/* 2> /dev/null;
$BB rm -rf /data/lost+found/* 2> /dev/null;
$BB rm -rf /data/tombstones/* 2> /dev/null;

# Prop tweaks
setprop persist.adb.notify 0
setprop persist.service.adb.enable 1
setprop pm.sleep_mode 1
setprop logcat.live disable
setprop profiler.force_disable_ulog 1
setprop ro.ril.disable.power.collapse 0
setprop persist.service.btui.use_aptx 1

# Google Services battery drain fixer by Alcolawl@xda
# http://forum.xda-developers.com/google-nexus-5/general/script-google-play-services-battery-t3059585/post59563859
pm enable com.google.android.gms/.update.SystemUpdateActivity
pm enable com.google.android.gms/.update.SystemUpdateService
pm enable com.google.android.gms/.update.SystemUpdateService$ActiveReceiver
pm enable com.google.android.gms/.update.SystemUpdateService$Receiver
pm enable com.google.android.gms/.update.SystemUpdateService$SecretCodeReceiver
pm enable com.google.android.gsf/.update.SystemUpdateActivity
pm enable com.google.android.gsf/.update.SystemUpdatePanoActivity
pm enable com.google.android.gsf/.update.SystemUpdateService
pm enable com.google.android.gsf/.update.SystemUpdateService$Receiver
pm enable com.google.android.gsf/.update.SystemUpdateService$SecretCodeReceiver

# Script finish here
rm /data/local/tmp/Imperium_Kernel
touch /data/local/tmp/Imperium_Kernel
echo "Imperium Kernel script correctly applied" > /data/local/tmp/Imperium_Kernel;

$BB mount -t rootfs -o remount,ro rootfs
$BB mount -o remount,rw /data

