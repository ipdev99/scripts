#!/bin/bash

# Mount image files from a factory image.
# ipdev @ xda-developers


# Set main variables
TDIR=$(pwd)
OUT=$TDIR/system

# # Set alternative directory.
# OUT=/ip/$NAME

# Set functions

convert_image() {
	echo "Converting" $i "to raw_"$i
	simg2img $i raw_$i
}

# check_dir() {
# 	[[ ! -d $OUT ]] && mkdir -p $OUT;
# 	[[ ! -d $SDIR ]] && mkdir -p $SDIR;
# }

mount_raw_image() {
	echo "Mounting "$ii;
	echo " "$OUT/$ii;
	#[[ ! -d $OUT ]] && mkdir -p $OUT;
	# [[ ! -d $OUT/$ii/ ]] && mkdir -p $OUT/$ii;
	sudo mount -o ro raw_$i $OUT/$ii
}


# Lets go.

echo "";

# Convert sparse image file(s) to raw image file(s).

simglist="system.img system_ext.img product.img vendor.img"

for i in $simglist; do
	if [ -f $i ]; then
		if [ ! -f raw_$i ]; then
			convert_image;
		fi;
	fi;
done;

# Mount the raw image file(s).

# Mount system first.
echo "Mounting system";
echo " "$OUT;
[[ ! -d $OUT ]] && mkdir $OUT;
sudo mount -o ro raw_system.img $OUT;

# Mount the rest.
rimglist="system_ext.img product.img vendor.img"

for i in $rimglist; do
	ii=$(printf "$i" | cut -f1 -d '.');
	mount_raw_image;
done;


# Done.
echo ""; echo "Done"; echo "";
exit 0;
