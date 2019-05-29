#!/bin/sh

DEST="$1"
if ! [ -d "$DEST" ]; then
	echo "Get target dir as parameter"
	exit 1
fi

umount --recursive "$DEST"
sync
