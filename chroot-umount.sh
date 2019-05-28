#!/bin/sh

DEST=/mnt

umount $DEST/proc
umount $DEST/sys
umount $DEST/tmp
umount $DEST/var/tmp
umount $DEST/dev/shm
umount $DEST/dev/pts
umount $DEST/dev

sync
