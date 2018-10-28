.FORCE:

define PARTITIONS =
label: dos\n\
unit: sectors\n\
\n\
: start=8192, size=114688, type=1, type=c\n\
: start=122880, type=83\n
endef

define SOURCES = 
deb	http://raspbian.raspberrypi.org/raspbian stretch main non-free firmware rpi\n\
deb	http://archive.raspberrypi.org/debian stretch main\n
endef
BOOTSTRAP := http://raspbian.raspberrypi.org/raspbian

define SOURCES = 
deb	http://localhost/raspbian stretch main non-free firmware rpi\n
endef
BOOTSTRAP := http://localhost/raspbian

PACKAGES := apt apt-transport-https bluez bluez-firmware btrfs-tools busybox-static bzip2 ca-certificates cron deborphan firmware-atheros firmware-brcm80211 firmware-libertas firmware-linux-free firmware-misc-nonfree firmware-realtek gzip htop ifupdown init iptables iputils-ping irqbalance isc-dhcp-client less libraspberrypi-bin libraspberrypi0 make net-tools nmap ntpdate openssh-client openssh-server p7zip-full raspberrypi-bootloader raspberrypi-kernel rpi-update rsync ssh sshfs sudo systemd traceroute unace unrar-free unzip vim wget wireless-tools wpasupplicant xz-utils zip

raspi_root: /usr/bin/qemu-arm-static
	btrfs subvolume create "$@" || mkdir "$@"
	mkdir -p "$@/usr/bin"
	chmod 755 -R "$@/"
	cp -p "$<" "$@/usr/bin/"
	debootstrap --keyring=./raspbian-archive-keyring.gpg \
		--arch=armhf --variant=minbase \
		stretch "$@/" "${BOOTSTRAP}"

raspi_root/: raspi_root .FORCE
	printf '${SOURCES}' >$@/etc/apt/sources.list
	-chroot "$@" apt-key add - <./raspberrypi-archive-keyring.gpg
	-cp /etc/resolv.conf "$@etc/"
	# for tree in ${CONFIG}; do for file in apt default timezone; do cp -av "$$tree/etc/$$file" "$@/etc/" || true; done; done
	-chroot "$@" sh -c 'apt-mark showmanual |xargs apt-mark auto'
	-chroot "$@" apt-get update
	chroot "$@" ln -sf /bin/true /usr/local/sbin/invoke-rc.d
	chroot "$@" apt-get --yes install ${PACKAGES}
	chroot "$@" apt-get --yes --auto-remove purge
	chroot "$@" apt-get --yes --auto-remove upgrade
	chroot "$@" rm /usr/local/sbin/invoke-rc.d
	chroot "$@" apt-get clean
	touch "$@"

raspi.img: raspi_root/
	-rmdir "$@.mnt"
	mkdir "$@.mnt"
	dd bs=1M count=0 seek=1024 of="$@"
	printf '${PARTITIONS}' |sfdisk "$@"
	lo=$$(losetup -f); image='$@'; \
	start=$$(sfdisk --dump "$$image" |sed -rn 's;^.*start= *([0-9]+),.*type=83;\1;p'); \
	size=$$(sfdisk --dump "$$image" |sed -rn 's;^.*size= *([0-9]+),.*type=83;\1;p'); \
	losetup -o $$((start * 512)) --sizelimit $$((size * 512)) "$${lo}" "$$image" && \
	mkfs.ext4 "$$lo" && mount -t ext4 "$$lo" "$@.mnt/";
	mkdir "$@.mnt/boot"
	lo=$$(losetup -f); image='$@'; \
	start=$$(sfdisk --dump "$$image" |sed -rn 's;^.*start= *([0-9]+),.*type=c;\1;p'); \
	size=$$(sfdisk --dump "$$image" |sed -rn 's;^.*size= *([0-9]+),.*type=c;\1;p'); \
	losetup -o $$((start * 512)) --sizelimit $$((size * 512)) "$${lo}" "$$image" && \
	mkfs.vfat "$$lo" && mount -t vfat "$$lo" "$@.mnt/boot";
	rsync -av "$<" "$@.mnt/"
	umount "$@.mnt/boot/" "$@.mnt/"
	losetup -a |sed -rn '/$@/{s;^([^:]+):.*$$;\1;p;q}' |xargs losetup -d
	losetup -a |sed -rn '/$@/{s;^([^:]+):.*$$;\1;p;q}' |xargs losetup -d
	rmdir "$@.mnt/"
