#!/bin/bash

## chroot mount [param1] [param2]
## both params could be device or mountpoint
## if nothing given, autodetection is done


# Note, the last entry wins
my_devices=( '/dev/disk/by-label/live' )
my_mountpoints=( '/mnt' '/gentoo' '/mnt/usb_live/' )

# Check if given path is a valid root
function check_valid_root(){
	if [ "$1" == "/" ] || [ "$1" == "" ]; then
		echo '"'$1'" is not valid root for chroot' / 1>&2
		return
	fi

	if [ -d "$1" ] &&
			[ -d "$1"/proc ] &&
			[ -d "$1"/dev ] &&
			[ -d "$1"/sys ]; then
		echo "$1"
	fi
}

# Check if any device already mounted
function check_mounted(){
	# Add parameters to the search
	if [ -n "$1" ]; then
		my_devices+=("$1")
		my_mountpoints+=("$1")
	fi
	if [ -n "$2" ]; then
		my_devices+=("$2")
		my_mountpoints+=("$2")
	fi

	mount | while read -r dev _ mpoint _; do
		for device in "${my_devices[@]}"; do
			realdev="$(realpath "$dev" 2>/dev/null)"
			realdevice="$(realpath "$device" 2>/dev/null)"
			if [ -n "$realdev" ] &&
					[ -n "$realdevice" ] &&
					[ "$realdev" == "$realdevice" ]; then
				NMP="$(check_valid_root "$mpoint")"
				if [ -n "$NMP" ]; then
					DEV="$dev"
					DEST="$mpoint"
				fi
			fi
		done

		for mountp in "${my_mountpoints[@]}"; do
			if [ "$mountp" == "$mpoint" ]; then
				NMP="$(check_valid_root "$mpoint")"
				if [ -n "$NMP" ]; then
					DEV="$dev"
					DEST="$mpoint"
				fi
			fi
		done

		if [ -n "$DEST" ]; then
			echo "$DEST"
			echo "use mounted device $DEV at $DEST" > /dev/tty
			exit
		fi
	done
}

# Check if any device and mountpoint available
function check_automount(){
	for device in "${my_devices[@]}"; do
		if [ -b "$device" ]; then
			DEV="$device"
		fi
	done

	for mountp in "${my_mountpoints[@]}"; do
		if [ -d "$mountp" ] &&  [ ! "$(ls "$mountp")" ]; then
			DEST="$mountp"
		fi
	done

	if [ -n "$DEV" ] && [ -n "$DEST" ] ; then
		echo "Mount device $DEV to $DEST" > /dev/tty
		mount -v "$DEV" "$DEST" > /dev/tty
		echo "$DEST"
	fi
}

function do_mount(){
	SRC="$1"
	shift
	FULL_DEST="$DEST""$SRC"
	if ! [ -d "$FULL_DEST" ]; then
		echo "No target $FULL_DEST"
		return
	fi
	if [ -n "$(findmnt -n "$FULL_DEST")" ]; then
		echo "already mounted" "$FULL_DEST"
	else
		mount -v "${@}" "$SRC" "$FULL_DEST"
	fi
}

function do_mount_portage(){
# Mount portage tree
	if [ -d /usr/portage ]; then
		SRC_PORTAGE=/usr/portage
	elif [ -d /var/db/repos/gentoo ]; then
		SRC_PORTAGE=/var/db/repos/gentoo
	else
		echo "No gentoo portage found"
		return
	fi

	if [ -d "$DEST"/usr/portage ]; then
		DST_PORTAGE="$DEST"/usr/portage
	elif [ -d "$DEST"/var/db/repos/gentoo ]; then
		DST_PORTAGE="$DEST"/var/db/repos/gentoo
	else
		echo "No target gentoo portage found"
		return
	fi
	mount -v -o rbind,rslave "$SRC_PORTAGE" "$DST_PORTAGE"

# Mount portage distfiles
	if [ -d /usr/portage/distfiles ]; then
		SRC_DISTFILES=/usr/portage/distfiles
	elif [ -d /var/cache/distfiles ]; then
		SRC_DISTFILES=/var/cache/distfiles
	else
		echo "No distfiles found"
		return
	fi

	if [ -d "$DEST"/usr/portage/distfiles ]; then
		DST_DISTFILES="$DEST"/usr/portage/distfiles
	elif [ -d "$DEST"/var/cache/distfiles ]; then
		DST_DISTFILES="$DEST"/var/cache/distfiles
	else
		echo "No target distfiles found"
		return
	fi
	mount -v -o rbind,rslave "$SRC_DISTFILES" "$DST_DISTFILES"
}

# Check if given parameter is valid root
if [ -n "$1" ] && [ -z "$2" ]; then
	DEST="$(check_valid_root "$1")"
	if [ -n "$DEST" ]; then
		echo "Use valid root $1"
	fi
fi

if [ -z "$DEST" ]; then
	DEST="$(check_mounted "${@}")"
fi

if [ -z "$DEST" ]; then
	DEST="$(check_automount)"
	if [ -z "$DEST" ]; then
		echo "No device found, exit"
		exit
	fi
fi

export DEST

do_mount /dev -o rbind,rslave
do_mount /sys -o rbind,rslave
do_mount /proc -t proc

do_mount_portage

RAMSIZE=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
if [ "$RAMSIZE" -ge 7701484 ]; then  # If RAM > 8 GB
	mount -v  -t tmpfs -o size=100% tmpfs "$DEST"/tmp
	mount -v  -t tmpfs -o size=100% tmpfs "$DEST"/var/tmp
fi

rm "$DEST"/etc/resolv.conf
cp /etc/resolv.conf "$DEST"/etc/resolv.conf

echo "-------------------------------------------------"
echo "$DEST prepared. Enter with chroot $DEST /bin/bash"
