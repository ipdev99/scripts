#!/bin/bash

# Template file to uniform my run build script.
# Make the appropriate changes and save as mk_DeviceName.sh
# Example. mk_manta.sh - mk_flo.sh - mk_deb.sh - mk_bonito.sh


# Set build variables

# # Build abc
# BUILD=abc
# DEVICE=bonito
# MKBUILD=abc_bonito-user
# OS=abc11

# # Build LineageOS
# BUILD=lineage
# DEVICE=manta
# MKBUILD=manta
# OS=l16

# Set main variables
TDIR=$(pwd)
LOGDIR=$TDIR/xfiles/logs

## DATE=$(date '+%Y%m%d')
# Use UTC/GMT (-u) date
DATE=$(date -u '+%Y%m%d')

# Set alternate for final directory. Leave blank if not used.
# ALTDIR=
ALTDIR=/home/ip/ip/roms
# ALTDIR=/builds

# Set logfile using UTC/GMT (-u) date and time.
LOGFILE="$LOGDIR"/$(date -u '+%Y%m%d_%H%M')_"$DEVICE"_"$OS".log

# Set main functions

make_md5sum() {
	md5sum boot-$OTANAME.img > boot-$OTANAME.img.md5sum;
	# md5sum $OTANAME.zip > $OTANAME.zip.md5sum;
	# md5sum recovery-$OTANAME.img > recovery-$OTANAME.img.md5sum;
}

make_sha256sum() {
	sha256sum boot-$OTANAME.img > boot-$OTANAME.img.sha256;
	sha256sum $OTANAME.zip > $OTANAME.zip.sha256;
	# sha256sum recovery-$OTANAME.img > recovery-$OTANAME.img.sha256;
}

move_to_finaldir() {
	[[ ! -d $FINALDIR ]] && mkdir -p $FINALDIR;
	mv boot-$OTANAME.img $FINALDIR;
	mv boot-$OTANAME.img.md5sum $FINALDIR;
	mv boot-$OTANAME.img.sha256 $FINALDIR;
	mv $OTANAME.zip $FINALDIR;
	mv $OTANAME.zip.md5sum $FINALDIR;
	mv $OTANAME.zip.sha256 $FINALDIR;
	# mv recovery-$OTANAME.img $FINALDIR;
	# mv recovery-$OTANAME.img.md5sum $FINALDIR;
	# mv recovery-$OTANAME.img.sha256 $FINALDIR;
}

remove_previous_files() {
	if [ -f boot-$OTANAME.img ]; then rm boot-$OTANAME.img; fi;
	if [ -f boot-$OTANAME.img.md5sum ]; then rm boot-$OTANAME.img.md5sum; fi;
	if [ -f boot-$OTANAME.img.sha256 ]; then rm boot-$OTANAME.img.sha256; fi;
	if [ -f recovery-$OTANAME.img ]; then rm recovery-$OTANAME.img; fi;
	if [ -f recovery-$OTANAME.img.md5sum ]; then rm recovery-$OTANAME.img.md5sum; fi;
	if [ -f recovery-$OTANAME.img.sha256 ]; then rm recovery-$OTANAME.img.sha256; fi;
	if [ -f $OTANAME.zip.sha256 ]; then rm $OTANAME.zip.sha256; fi;
}

rename_files() {
	[ -f boot.img ] && mv boot.img boot-$OTANAME.img;
	# [ -f recovery.img ] && mv recovery.img recovery-$OTANAME.img;
}

# Make Log directory if needed.
[[ ! -d $LOGDIR ]] && mkdir -p $LOGDIR;

# Set alternate final directory if used.
## [[ -n $ALTDIR ]] && FINALDIR=$ALTDIR/$OS/$DATE/;
[[ -n $ALTDIR ]] && FINALDIR=$ALTDIR/$OS/$DEVICE/$DATE/;

# Start time elapsed.
STE=$(date +%s)

## source build/envsetup.sh does not seem to work when using 2>&1 | tee -a "$LOGFILE".
echo "Build enviroment"
source build/envsetup.sh # 2>&1 | tee -a "$LOGFILE"
echo "" >> "$LOGFILE"

## The brunch command fails when running make clean using 2>&1 | tee -a "$LOGFILE".
echo "Make clean"
make clean # 2>&1 | tee -a "$LOGFILE"
## echo "" >> "$LOGFILE"

# Start build time
SBT=$(date +%s)

# Might be needed for LineageOS builds.
## export TEMPORARY_DISABLE_PATH_RESTRICTIONS=true

# Start build
echo "Start build (brunch)"
brunch "$MKBUILD" 2>&1 | tee -a "$LOGFILE"

# End build time
EBT=$(date +%s)
secs=$(( ${EBT}-${SBT} ))

echo "Build time:" | tee -a "$LOGFILE"
printf '%d Hour(s) %d Minute(s) %d Second(s)\n' $(($secs/3600)) $(($secs%3600/60)) $(($secs%60))
printf '%d Hour(s) %d Minute(s) %d Second(s)\n' $(($secs/3600)) $(($secs%3600/60)) $(($secs%60)) 2>&1 >> "$LOGFILE"
echo "" | tee -a "$LOGFILE"

# Restore PATH
source ~/.bash_profile

# Check and set the ota name

if [ "$BUILD" = "abc" ]; then
	if [ -f out/target/product/"$DEVICE"/abc_"$DEVICE"-v*.zip ]; then
		OTANAME=$(find out/target/product/"$DEVICE"/abc_"$DEVICE"-v*.zip | sed 's/.zip//g' | cut -f5 -d'/');
	fi;
fi;

if [ "$BUILD" = "lineage" ]; then
	if [ -f out/target/product/"$DEVICE"/lineage-*.zip ]; then
		OTANAME=$(find out/target/product/"$DEVICE"/lineage-*.zip | sed 's/.zip//g' | cut -f5 -d'/');
	fi;
fi;

# Change to out directory
[[ -n $OTANAME ]] && cd "$TDIR"/out/target/product/"$DEVICE"/;

# Delete previous versions (if exist) that are named the same as the new version.
# Rename new versions. Make md5sum and sha256sum files for boot, system and recovery.
if [ -n "$OTANAME" ]; then
	remove_previous_files;
	rename_files;
	make_md5sum;
	make_sha256sum;
fi;

# Move to an alternative final directory.
if [ -n "$OTANAME" ] && [ -n "$FINALDIR" ]; then
	move_to_finaldir;
fi;

# End time elapsed.
ETE=$(date +%s)
secs=$(( ${ETE}-${STE} ))

echo "Total time elapsed:" | tee -a "$LOGFILE"
printf '%d Hour(s) %d Minute(s) %d Second(s)\n' $(($secs/3600)) $(($secs%3600/60)) $(($secs%60))
printf '%d Hour(s) %d Minute(s) %d Second(s)\n' $(($secs/3600)) $(($secs%3600/60)) $(($secs%60)) 2>&1 >> "$LOGFILE"
echo ""

# Finish script
echo ""; echo " Done."; echo "";

if [ -n "$OTANAME" ] && [ -n "$FINALDIR" ]; then
	echo " New file(s) moved to "$FINALDIR""; echo "";
fi;

#
exit 0;
