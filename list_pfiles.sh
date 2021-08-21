#!/system/bin/sh

# List preinstalled files recursively.
# ipdev @ xda-developers

# To Use:
#
# Copy this script to the device.
#  Recommended to use the /sdcard/Download/ directory.
#
# Run from adb shell (or a terminal app) using the sh command.
#  sh list_pfiles.sh
#
# Run from a file manager that is able to execute a script file.
#  Note: May or may not work depending on file manager..

# Set main variables

DATE=$(date '+%Y%m%d')
# DATE=$(date '+%Y%m%d_%H%M')
TDIR=$(pwd)
SCRIPT=list_pfiles.sh

# Set main functions

check_android_device() {
	ANDROID=FALSE;
	[ -f /system/bin/sh ] || [ -f /system/bin/toybox ] || [ -f /system/bin/toolbox ] && ANDROID=TRUE;
}

set_target_directory() {
	if [ ! -f "$SCRIPT" ]; then
		TDIR=$(lsof 2>/dev/null | grep -o '[^ ]*$' | grep -m1 "$SCRIPT" | sed 's/\/'"$SCRIPT"'//g');
		cd $TDIR;
	fi
}

set_prop_file() {
	getprop | sed 's/\]: \[/=/g; s/\[//g; s/\]//g' > getprop.props;
	[ -f getprop.props ] && prop_file=getprop.props;
}

# Determine if running on an Android device.
check_android_device;

if [ "$ANDROID" = "FALSE" ]; then
	echo "";
	echo " This script needs to be run on an Android device. ";
	echo "";
	exit 0;
fi;

# Reset and move to the target directory if needed.
set_target_directory

# Set prop file to use.
set_prop_file

# Set variables
aOS=$(grep -m1 ro.build.version.release= $prop_file | cut -f2 -d '=');
SDK=$(grep -m1 ro.build.version.sdk $prop_file | cut -f2 -d '=');
BUTC=$(grep -m1 ro.build.date.utc $prop_file | cut -f2 -d '=');
# Add sed to remove double space in some build dates.
BDATE=$(grep -m1 ro.build.date= $prop_file | sed 's/  / /g' | cut -f2,3,6 -d ' ');

# Set variables for use in naming the $LOGFILE file.
# Remove spaces and change to lowercase so the file(s) should list in the correct order.

if grep -q ro.product.device= $prop_file; then
	LDEVICE=$(grep -m1 ro.product.device= $prop_file | cut -f2 -d '=' | tr [:upper:] [:lower:]);
elif grep -q ro.product.system.device $prop_file; then
	LDEVICE=$(grep -m1 ro.product.system.device $prop_file | cut -f2 -d '=' | tr [:upper:] [:lower:]);
elif grep -q ro.product.vendor.device $prop_file; then
	LDEVICE=$(grep -m1 ro.product.vendor.device $prop_file | cut -f2 -d '=' | tr [:upper:] [:lower:]);
else
	LDEVICE=$(grep -m1 ro.build.product= $prop_file | cut -f2 -d '=' | tr [:upper:] [:lower:]);
fi;

# if grep -q ro.product.name $prop_file; then
# 	LNAM=$(grep ro.product.name $prop_file | cut -f2 -d '=' | tr [:upper:] [:lower:]);
# else
# 	LNAM=$(grep ro.product.vendor.name $prop_file | cut -f2 -d '=' | tr [:upper:] [:lower:]);
# fi

if grep -q ro.product.model $prop_file; then
	LMODL=$(grep -m1 ro.product.model $prop_file | cut -f2 -d '=' | sed 's/ /_/g' | tr [:upper:] [:lower:]);
elif grep -q ro.product.vendor.model $prop_file; then
	LMODL=$(grep -m1 ro.product.vendor.model $prop_file | cut -f2 -d '=' | sed 's/ /_/g' | tr [:upper:] [:lower:]);
else
	LMODL=$(grep -m1 ro.product.system.model $prop_file | cut -f2 -d '=' | sed 's/ /_/g' | tr [:upper:] [:lower:]);
fi;

if grep -q ro.product.brand= $prop_file; then
	LBRND=$(grep -m1 ro.product.brand= $prop_file | cut -f2 -d '=' | tr [:upper:] [:lower:]);
elif grep -q ro.product.system.brand= $prop_file; then
	LBRND=$(grep -m1 ro.product.system.brand= $prop_file | cut -f2 -d '=' | tr [:upper:] [:lower:]);
else
	LBRND=$(grep -m1 ro.product.vendor.brand= $prop_file | sed '$!d' | cut -f2 -d '=' | tr [:upper:] [:lower:]);
fi;

if grep -q ro.product.manufacture $prop_file; then
	LMAN=$(grep -m1 ro.product.manufacture $prop_file | cut -f2 -d '=' | tr [:upper:] [:lower:]);
elif grep -q ro.product.vendor.manufacturer $prop_file; then
	LMAN=$(grep -m1 ro.product.vendor.manufacturer $prop_file | cut -f2 -d '=' | tr [:upper:] [:lower:]);
else
	LMAN=$(grep -m1 ro.product.system.manufacturer $prop_file | cut -f2 -d '=' | tr [:upper:] [:lower:]);
fi;

# Set LOGFILE file name.

# Generic
LOGFILE="$TDIR"/"$LBRND"_"$LMODL"_"$BUTC"_pfile.list

# Lets Go.

echo "Brand = "$LBRND"" >$LOGFILE
echo "Model =  "$LMODL"" >>$LOGFILE
echo "Device = "$LDEVICE"" >>$LOGFILE
echo "" >>$LOGFILE
echo "Android Version = "$aOS"" >>$LOGFILE
echo "SDK = "$SDK"" >>$LOGFILE
echo "Build Date = "$BDATE"" >>$LOGFILE
echo "Build UTC = "$BUTC"" >>$LOGFILE

echo "" >>$LOGFILE
find /system/app/ -type f >>$LOGFILE
echo "" >>$LOGFILE
find /system/priv-app/ -type f >>$LOGFILE
echo "" >>$LOGFILE
find /vendor/app/ -type f >>$LOGFILE
echo "" >>$LOGFILE
find /product/app/ -type f >>$LOGFILE
echo "" >>$LOGFILE
find /product/priv-app/ -type f >>$LOGFILE
echo "" >>$LOGFILE
find /data/app/ -type f >>$LOGFILE
echo "" >>$LOGFILE

# Finish script
rm $prop_file;

echo ""; echo " Done."; echo "";
echo " New file saved as "$LOGFILE""; echo "";

return 0; exit 0;
