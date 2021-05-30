#!/bin/bash

# Extract image files from OTA/ROM zip files.
# ipdev @ xda-developers

### Switch to using LineageOS scripts.
# For more information see the LineageOS wiki.
#
# Extracting proprietary blobs from LineageOS zip files
# https://wiki.lineageos.org/extracting_blobs_from_zips.html

# If you have a lineage build directory, you can point extract and sdat2img to it.
# Set $LBD to your lineage build directory.

# If you do not have a lineage build directory, you can clone lineage scripts into a directory.
# Then set $LBD to your directory that you cloned the scripts into.
#
# You can also clone the lineage scripts into the same directory as the OTA/ROM zip file.

# To clone the Lineage scrips directory to you current directory.
# git clone https://github.com/LineageOS/scripts
# git clone https://github.com/xpirt/sdat2img


# Set main variables
TDIR=$(pwd)

# Set lineage build directory.
LBD=/home/ip/build/l18

# Use python scripts from lineage build directory (LBD).
EXTRACT=$LBD/lineage/scripts/update-payload-extractor/extract.py
SDAT2IMG=$LBD/tools/extract-utils/sdat2img.py

# # Use python scripts cloned into the same directory as the zip file.
# EXTRACT=$TDIR/scripts/update-payload-extractor/extract.py
# SDAT2IMG=$TDIR/sdat2img/sdat2img.py

# Set main functions

run_brotli(){
	echo "Decompressing";
	for i in *.br; do
		{
			ii=$(printf "$i" | sed 's/.br//g');
			echo " "$i" to "$ii;
			brotli --decompress --output=$ii $i > /dev/null 2>&1;
			rm $i;
			[[ ! -f $ii ]] && echo " - Failed";
			[[ -f $ii ]] && echo " - Complete";
		}
	done;
}

run_extract(){
	echo "Extracting payload from "$NAME;
	python3 $EXTRACT payload.bin --output_dir $(pwd); # > /dev/null 2>&1;
	rm payload.bin;
}

run_sdat2img(){
	echo "Converting";
	for i in *.dat; do
		{
			ii=$(printf "$i" | cut -f1 -d '.');
			echo " "$i" to "$ii.img;
			python3 $SDAT2IMG $ii.transfer.list $ii.new.dat $ii.img > /dev/null 2>&1;
			rm $i;
			rm $ii.transfer.list;
			[[ ! -f $ii.img ]] && echo " - Failed";
			[[ -f $ii.img ]] && echo " - Complete";
		}
	done;
}


# Set additional functions

# ________ None __________


# Lets go.

for zip in *.zip; do
	{
		NAME=$(printf "$zip" | sed 's/.zip//g');
		unzip "$zip" "*new.dat.br" "*new.dat" "*.list" "boot.img" "payload.bin" "recovery.img" -d $NAME > /dev/null 2>&1;
		cd $TDIR/$NAME;
		[[ -n "$(find -maxdepth 1 -name '*.br' | grep -m1 'br')" ]] && run_brotli;
		[[ -n "$(find -maxdepth 1 -name '*.dat' | grep -m1 'dat')" ]] && run_sdat2img;
		[[ -f payload.bin ]] && run_extract;
		cd $TDIR;
	}
done;

# # clean up
# find -depth -empty -delete;

# Done.
echo ""; echo "Done"; echo "";
exit 0;
