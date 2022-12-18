#!/bin/bash

# Pull the boot image(s) from a Pixel factory image zip file(s).
# ipdev @ xda-developers

TDIR=$(pwd)
OUT="$TDIR"/boot

# Set main functions

check_dir() {
  [[ ! -d $OUT ]] && mkdir -p $OUT;
}

# ____ Here we go. ____

# Check and create directory(s) if needed.
check_dir

for i in *.zip; do
  {
    unzip "$i" "*.zip" -d tmp
    NAME=$(printf "$i" | cut -f1,2 -d '-');
    unzip tmp/"$NAME"/image-*.zip "*boot.img" -d "$TDIR"
    rm -rf tmp
    for ii in *.img; do
      {
        mv "$ii" "$OUT"/"$NAME"-"$ii"
      }
    done
  }
done

exit 0;
