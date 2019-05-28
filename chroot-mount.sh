#!/bin/sh

DEST=/mnt

mount -o bind /dev/ $DEST/dev/
mount -o bind /dev/pts $DEST/dev/pts
mount -t tmpfs temp -o rw,nosuid,nodev,noexec,relatime $DEST/dev/shm

mount -o bind /sys/ $DEST/sys/
mount -t proc proc  $DEST/proc/
mount -t tmpfs temp -o size=100% $DEST/tmp
mount -t tmpfs temp -o size=100% $DEST/var/tmp

rm $DEST/etc/resolv.conf
cp /etc/resolv.conf $DEST/etc/resolv.conf
