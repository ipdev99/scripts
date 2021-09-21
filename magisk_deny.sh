#!/system/bin/sh

# Add package processes to the Magisk DenyList.
# Requires root access.
#
# ipdev @ xda-developers

#--------------------------------------------------------------------------------
# Magisk - Multi-purpose Utility

# Usage: magisk [applet [arguments]...]
#    or: magisk [options]...

# Options:
#    -c                        print current binary version
#    -v                        print running daemon version
#    -V                        print running daemon version code
#    --list                    list all available applets
#    --remove-modules          remove all modules and reboot
#    --install-module ZIP      install a module zip file

# Advanced Options (Internal APIs):
#    --daemon                  manually start magisk daemon
#    --stop                    remove all magisk changes and stop daemon
#    --[init trigger]          start service for init trigger
#                              Supported init triggers:
#                              post-fs-data, service, boot-complete
#    --unlock-blocks           set BLKROSET flag to OFF for all block devices
#    --restorecon              restore selinux context on Magisk files
#    --clone-attr SRC DEST     clone permission, owner, and selinux context
#    --clone SRC DEST          clone SRC to DEST
#    --sqlite SQL              exec SQL commands to Magisk database
#    --path                    print Magisk tmpfs mount path
#    --denylist ARGS           denylist config CLI

# Available applets:
#     su, resetprop


# "DenyList Config CLI

# Usage: magisk --denylist [action [arguments...] ]
# Actions:
#    status          Return the enforcement status
#    enable          Enable denylist enforcement
#    disable         Disable denylist enforcement
#    add PKG [PROC]  Add a new target to the denylist
#    rm PKG [PROC]   Remove target(s) from the denylist
#    ls              Print the current denylist
#    exec CMDs...    Execute commands in isolated mount
#                    namespace and do all unmounts
#--------------------------------------------------------------------------------

# Set main variables

TDIR=$(pwd)
SCRIPT=magisk_deny.sh

# Set additional variables
# MINMAGISKVER=

# Set main functions

check_android_device() {
	[ -f /system/bin/sh ] || [ -f /system/bin/toybox ] || [ -f /system/bin/toolbox ] && ANDROID=TRUE;
	if [[ -z $ANDROID ]]; then
		echo ""; echo " This script needs to be run on an Android device. "; echo "";
		exit 0;
	fi;
}

set_target_directory() {
	if [ ! -f "$SCRIPT" ]; then
		TDIR=$(lsof 2>/dev/null | grep -o '[^ ]*$' | grep -m1 "$SCRIPT" | sed 's/\/'"$SCRIPT"'//g');
		cd $TDIR;
	fi;
}

# Set additional functions

set_defualt_list() {
	magisk su -c magisk --denylist add com.google.android.gms com.google.android.gms.unstable;
	if [[ $(magisk su -c magisk --path) != /sbin ]]; then
		magisk su -c magisk --denylist add com.google.android.gms com.google.android.gms;
	fi;
}

check_deny_list() {
	magisk su -c magisk --denylist status > /dev/null;
	if [ $? -ne 0 ]; then
		magisk su -c magisk --denylist enable;
		magisk su -c magisk --denylist status > /dev/null;
		if [ $? -ne 0 ]; then
			echo ""; echo " You need to enable Zygisk first. "; echo "";
			exit 0;
		fi;
	fi;
}

check_magisk_ver(){
	MAGISKVER=$(magisk -V 2> /dev/null);
	if [[ -z $MAGISKVER ]]; then
		echo ""; echo " This script reqires Magisk to be installed and active. "; echo "";
		exit 0;
	else
		MAGISKBLD=$(magisk -v | cut -f1 -d ':');
	fi;

	# if [[ $MAGISKVER -ne $MINMAGISKVER ]]; then
	# 	echo ""; echo " This script reqires Magisk "$MINMAGISKVER" to be installed and active. "; echo "";
	# 	exit 0;
	# fi;
}

# Lets go.

# Determine if running on an Android device.
check_android_device;

# Reset and move to the target directory if needed.
set_target_directory;

# Determine if Magisk is installed and running.
check_magisk_ver;

# #### Ignore. ........................
## Just some more script testing.
#
# echo $MAGISKVER;
# echo $MAGISKBLD;
#
# for i in $(magisk --denylist ls); do
# 	ii=$(printf "$i" | sed 's/|/ /g');
# 	magisk --denylist rm $ii;
# done;
#
# #### ................................

# Check the status and try to enable Enforce DenyList if Denylist is not enforced.
check_deny_list;

# Set the last MagiskHide defualt list.
set_defualt_list;

# Add more to the list.
## magisk su -c magisk --denylist add name.of.package name.of.process;

## Example.
## magisk su -c magisk --denylist add com.google.android.gms com.google.android.gms.unstable;

# RootBeerFresh (This is an active example. You can delete this line and the following line.)
magisk su -c magisk --denylist add com.kimchangyoun.rootbeerFresh.sample com.kimchangyoun.rootbeerFresh.sample;


# Cleanup


# Finish script

echo ""; echo " Done."; echo "";
return 0; exit 0;