# Chroot-Scripts
Prepare a system root to be mounted in chroot. Search for valid Handle all submounts like sys or proc

License: GPL-3

How to use


| Call | Task|
| -------- | -------- |
|`./chroot-mount.sh` | Search trough hardcoded device and mountpoint lists for useable root. Mount if necessary |
|`./chroot-mount.sh /dev/sdX` | Use given mounted device, or mount them any hardcoded empty mountpoint |
|`./chroot-mount.sh /any/path` | Use given path if not empty and valid root |
|`./chroot-mount.sh /any/path` | Use the path to mount any hardcoded device if found |
|`./chroot-mount.sh /dev/sdX /any/path` | Use the device if mounted. Mount them to given path if not mounted |
|`./chroot-umount.sh /any/path` | Umount all sub-mounts. The root device remains mounted |

