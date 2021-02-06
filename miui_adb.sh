#!/system/bin/sh

# Enable adb install on miui OS when not logged into mi-account.
# ipdev @ xda-developers

# The setprop command requires root access.
# Make sure to grant root (su) access to adb shell,
# the terminal app or the file manager used.

# To Use:
#
# Copy this script to the device.
#  Recommended to use the /sdcard/Download/ directory.
#
# Run from adb shell (or a terminal app) as root using the sh command.
#  sh miui_adb,sh
#
# Run from a file manager that is able to execute a script file as root.

# Note: Setting persist.security.adbinput will reset the usb connection.
# If running the script from adb shell, you will have to reconnect adb and
# run the script a second time.

# Set main variables

TDIR=$(pwd)
SCRIPT=miui_adb.sh

# Set main functions

check_android_device() {
	ANDROID=FALSE;
	[ -f /system/bin/sh ] || [ -f /system/bin/toybox ] || [ -f /system/bin/toolbox ] && ANDROID=TRUE;
}

set_target_directory() {
	if [ ! -f "$SCRIPT" ]; then
		TDIR=$(lsof 2>/dev/null | grep -o '[^ ]*$' | grep -m1 "$SCRIPT" | sed 's/\/'"$SCRIPT"'//g');
		cd $TDIR;
	fi;
}

# Determine if running on an Android device.

check_android_device;

if [ "$ANDROID" = "FALSE" ]; then
	echo " This script needs to be run on an Android device. ";
	exit 0;
fi;

# Reset and move to the target directory if needed.

set_target_directory;

# Add missing props for adb on miui OS.

if [ ! $(getprop persist.security.adbinput) ]; then
	setprop persist.security.adbinput 1;
	ADBINPUT=1;
elif [ $(getprop persist.security.adbinput) -ne 1 ]; then
	resetprop persist.security.adbinput 1;
	ADBINPUT=1;
fi;

if [ ! $(getprop persist.security.adbinstall) ]; then
	setprop persist.security.adbinstall 1;
	ADBINSTALL=1;
elif [ $(getprop persist.security.adbinstall) -ne 1 ]; then
	resetprop persist.security.adbinstall 1;
	ADBINSTALL=1;
fi;

# Note changes.

if [[ -z $ADBINPUT ]] | [[ -z $ADBINSTALL ]]; then
	echo""; echo " No change needed.";
	echo "  $(getprop | grep persist.security.adbinput | sed 's/\]: \[/=/g; s/\[//g; s/\]//g')";
	echo "  $(getprop | grep persist.security.adbinstall | sed 's/\]: \[/=/g; s/\[//g; s/\]//g')";
fi;

if [[ -n $ADBINPUT ]]; then
	echo ""; echo " persist.security.adbinput has been set to 1";
	echo "  $(getprop | grep persist.security.adbinput | sed 's/\]: \[/=/g; s/\[//g; s/\]//g')";
fi;

if [[ -n $ADBINSTALL ]]; then
	echo ""; echo " persist.security.adbinstall has been set to 1";
	echo "  $(getprop | grep persist.security.adbinstall | sed 's/\]: \[/=/g; s/\[//g; s/\]//g')";
fi;

# Finish script

echo ""; echo " Done."; echo "";
return 0; exit 0;
