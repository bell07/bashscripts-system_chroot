#!/bin/sh

DEST="$1"
if ! [ -d "$DEST" ]; then
	echo "Get target dir as parameter"
	exit 1
fi

# Just try umount. Show error if failed
umount --recursive "$DEST"/dev
umount --recursive "$DEST"/sys
umount "$DEST"/proc
umount --recursive "$DEST"/usr/portage
umount --recursive "$DEST"/tmp
umount --recursive "$DEST"/var/tmp
sync
