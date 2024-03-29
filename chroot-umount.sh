#!/bin/sh

DEST="$1"
if ! [ -d "$DEST" ]; then
	echo "Get target dir as parameter"
	exit 1
fi

if [ "$DEST" == "/" ] || [ "$DEST" == "" ]; then
	echo '"'$1'" is not valid root for chroot'
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
do_umount var/db/repos/gentoo
do_umount var/cache/distfiles
do_umount tmp
do_umount var/tmp
sync
