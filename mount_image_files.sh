#!/bin/bash

# Mount image files from a factory image.
# ipdev @ xda-developers


# Set main variables
TDIR=$(pwd)
OUT=$TDIR/system

# # Set alternative directory.
# OUT=/ip/$NAME

# Set main functions

convert_image() {
	echo "- Sparse image file. -"
	if [ ! -f raw_$i ]; then 
	  echo "Converting" $i "to raw_"$i
	  simg2img $i raw_$i
	fi
}

mount_image() {
	echo "Mounting "$ii
	echo " "$OUT/$ii
	sudo mount -o ro $i $OUT/$ii > /dev/null 2>&1
	if [ $? -ne 0 ]; then
	  convert_image
	  sudo mount -o ro raw_$i $OUT/$ii > /dev/null 2>&1
	  if [ $? -ne 0 ]; then
	  	echo " ! Error mounting "$ii
	  fi
	fi
}

mount_system() {
	echo "Mounting "$ii
	echo " "$OUT
	[[ ! -d $OUT ]] && mkdir -p $OUT
	sudo mount -o ro $i $OUT > /dev/null 2>&1
	if [ $? -ne 0 ]; then
	  convert_image
	  sudo mount -o ro raw_$i $OUT > /dev/null 2>&1
	  if [ $? -ne 0 ]; then
	  	echo " ! Error mounting "$ii
	  fi
	fi
}

# Lets go.

echo ""

# __ Mount the image file(s). __

# Mount system first.
for i in system.img; do
  ii=$(printf "$i" | cut -f1 -d '.')
  mount_system
done


# Mount the rest.
imglist="system_ext.img product.img vendor.img"

for i in $imglist; do
	if [ -f $i ]; then
		ii=$(printf "$i" | cut -f1 -d '.')
		mount_image
	fi
done


# Clean up.

# Done.
echo ""; echo "Done"; echo "";
exit 0;
