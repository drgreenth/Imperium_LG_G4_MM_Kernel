#!/system/bin/sh

BB=/sbin/busybox

$BB mount -o remount,rw /system

# Installing Busybox
/system/xbin/busybox --install -s /system/xbin/
$BB chmod 06755 /system/xbin/busybox

# Fixing su permissions
if [ -e /system/xbin/su ]; then
	$BB chmod 06755 /system/xbin/su;
fi;
if [ -e /system/xbin/daemonsu ]; then
	$BB chmod 06755 /system/xbin/daemonsu;
fi;

# Fixing ROOT
/system/xbin/daemonsu --auto-daemon &

# Start script in init.d folder
$BB run-parts /system/etc/init.d/

# Script finish here
rm /data/local/tmp/Imperium_Kernel
touch /data/local/tmp/Imperium_Kernel
echo "Imperium Kernel script correctly applied" > /data/local/tmp/Imperium_Kernel;

$BB mount -o remount,ro /system

