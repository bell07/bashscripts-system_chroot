#!/bin/sh

DEST="$1"
if ! [ -d "$DEST" ]; then
	echo "Get target dir as parameter"
	exit 1
fi

function do_umount(){
	umount -v --recursive "$DEST"/"$1"
}

# Just try umount. Show error if failed
do_umount dev
do_umount sys
do_umount proc
do_umount usr/portage
do_umount tmp
do_umount var/tmp
sync
