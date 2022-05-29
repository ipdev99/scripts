#!/system/bin/sh

# Run fstrim on cache, system and data.
# ipdev @ xda-developers


# To Use:
#
# Copy this script to the device.
#
# Run from adb shell (or a terminal app) as root using the sh command.
#  sh fstrim.sh
#
# Run from a file manager that is able to execute a script file as root.
#  Note: May or may not work depending on the file manager..

# Note:
#
# Currently fstrim is not included in Android.
#
# BusyBox is required.
#
# If BusyBox is not installed.
#  This script will use Magisk's BusyBox if it exists.

#________________________________________________________________________________________________________

# Description.
# fstrim is used on a mounted filesystem to discard (trim) blocks which are not in use by the filesystem.
# This is useful for solid-state drives (SSDs) and thinly-provisioned storage.

# Warning.
# Running fstrim frequently, might negatively affect the lifetime of poor-quality devices.
#________________________________________________________________________________________________________


# Running on an Android device?

[ -f /system/bin/sh ] || [ -f /system/bin/toybox ] || [ -f /system/bin/toolbox ] && ANDROID=TRUE;

if [[ -z $ANDROID ]]; then
        echo ""; echo " This script needs to be run an Android device."; echo "";
        exit 0
fi


# Running as root?

if [ ! "$(whoami)" = "root" ]; then
        echo ""; echo " This script needs to be run as root."; echo "";
        exit 0
fi


# Run fstrim on cache, system and data.

if [ $(command -v fstrim) ]; then
        fstrim -v /cache 2>&1
        fstrim -v /system 2>&1
        fstrim -v /data 2>&1
elif [ $(command -v /data/adb/magisk/busybox) ]; then
        /data/adb/magisk/busybox fstrim -v /cache 2>&1
        /data/adb/magisk/busybox fstrim -v /system 2>&1
        /data/adb/magisk/busybox fstrim -v /data 2>&1
else
        echo ""
        echo " The fstrim command is not currently included in Android."
        echo " BusyBox is required and not installed."
        echo ""
        echo " Install BusyBox before running this script again."
        echo ""
fi


# Finish script

echo ""; echo " Done."; echo "";
return 0; exit 0;
