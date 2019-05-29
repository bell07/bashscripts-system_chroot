#!/bin/sh

## chroot mount [param1] [param2]
## both params could be device or mountpoint
## if nothing given, autodetection is done


# Note, the last entry wins
my_devices=( '/dev/disk/by-label/live' )
my_mountpoints=( '/mnt' '/gentoo' '/mnt/usb_live/' )

# Check if any device already mounted
function check_mounted(){
	mount | while read dev _ mpoint _ type _; do
		for device in "${my_devices[@]}"; do
			realdev="$(realpath "$dev" 2>/dev/null)"
			realdevice="$(realpath "$device" 2>/dev/null)"
			if [ -n "$realdev" ] &&
					[ -n "$realdevice" ] &&
					[ "$realdev" == "$realdevice" ]; then
				DEV="$dev"
				DEST="$mpoint"
			fi
		done

		for mountp in "${my_mountpoints[@]}"; do
			if [ "$mountp" == "$mpoint" ]; then
				DEV="$dev"
				DEST="$mpoint"
			fi
		done

		if [ -n "$DEV" ]; then
			echo "$DEV" "$DEST"
			return
		fi
	done
}

# Check if any device and mountpoint available
function check_autodetect(){
	for device in "${my_devices[@]}"; do
		if [ -b "$device" ]; then
			DEV="$device"
		fi
	done

	for mountp in "${my_mountpoints[@]}"; do
		if [ -d "$mountp" ]; then
			DEST="$mountp"
		fi
	done

	if [ -n "$DEV" ] && [ -n "$DEST" ] ; then
		echo "$DEV" "$DEST"
		return
	fi
}

function do_mount(){
	SRC="$1"
	shift
	OPTIONS="$@"
	FULL_DEST="$DEST""$SRC"
	if ! [ -d "$FULL_DEST" ]; then
		echo "No target $FULL_DEST"
		return
	fi
	if [ -n "$(findmnt -n "$FULL_DEST")" ]; then
		echo "already mounted" "$FULL_DEST"
	else
		mount -v $OPTIONS "$SRC" "$FULL_DEST"
	fi
}

# Add parameters to the search
if [ -n "$1" ]; then
	my_devices+=($1)
	my_mountpoints+=($1)
fi

if [ -n "$2" ]; then
	my_devices+=($2)
	my_mountpoints+=($2)
fi

CHK_ARRAY=($(check_mounted))
DEV="${CHK_ARRAY[0]}"
DEST="${CHK_ARRAY[1]}"

if [ -n "$DEV" ]; then
	echo "already mounted" "$DEV" at "$DEST"
else
	CHK_ARRAY=($(check_autodetect))
	DEV="${CHK_ARRAY[0]}"
	DEST="${CHK_ARRAY[1]}"
	if [ -n "$DEV" ]; then
		mount -v "$DEV" "$DEST"
	else
		echo "No device found, exit"
		exit
	fi
fi

export DEST


do_mount /dev -o bind
do_mount /dev/pts -o bind
do_mount /dev/shm -t tmpfs -o rw,nosuid,nodev,noexec,relatime

do_mount /sys -o bind
do_mount /proc -t proc

RAMSIZE=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
if [ $RAMSIZE -ge 7701484 ]; then  # If RAM > 8 GB
	do_mount /tmp -t tmpfs -o size=100%
	do_mount /var/tmp -t tmpfs -o size=100%
fi

rm $DEST/etc/resolv.conf
cp /etc/resolv.conf $DEST/etc/resolv.conf

echo "-------------------------------------------------"
echo "$DEST prepared. Enter with chroot $DEST /bin/bash"
