# Chroot-Scripts

Prepare a system root to be mounted in chroot. Do all submounts like sys or proc.

License: GPL-3

## How to use:

Simple usage is
`chroot-mount.sh /mounted/root/path`


## Some additional device and path determinations is implemented to fulfill my needs:

| Call | Task|
| -------- | -------- |
|`chroot-mount.sh` | Search trough hardcoded device and mountpoint lists for useable root. Mount if necessary |
|`chroot-mount.sh /dev/sdX` | Use given mounted device, or mount them to any hardcoded empty mountpoint |
|`chroot-mount.sh /any/path` | Check if the path is a valid system root (/proc, /dev and /sys exists) and use it if true |
|`chroot-mount.sh /any/path` | Mount hard-coded device if found to the path and use it |
|`chroot-mount.sh /dev/sdX /any/path` | Use the device if mounted. Mount them to given path if not mounted |

|`chroot-umount.sh /any/path` | Umount all sub-mounts. The root device remains mounted |

### Hard-Coded devices are
- /dev/disk/by-label/live

### Hard-Coded mount points are
- /mnt/usb_live
- /gentoo
- /mnt
