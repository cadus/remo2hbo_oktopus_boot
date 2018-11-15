#  Generator for Oktopus boot media
#  Copyright (C) 2018 Hochschule für Technik und Wirtschaft Berlin
#                written by Paul Hänsch <oktopus@plutz.net>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Affero General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Affero General Public License for more details.
#
#  You should have received a copy of the GNU Affero General Public License
#  along with this program.  If not, see <https://www.gnu.org/licenses/>.

.FORCE:

BOOTSTRAP = http://raspbian.raspberrypi.org/raspbian

define SOURCES = 
deb	http://raspbian.raspberrypi.org/raspbian stretch main non-free firmware rpi\n\
deb	http://archive.raspberrypi.org/debian stretch main\n
endef

PACKAGES := apt bluez bluez-firmware bluez-tools bridge-utils btrfs-tools busybox-static bzip2 ca-certificates cron deborphan dnsmasq firmware-brcm80211 firmware-linux-free firmware-misc-nonfree gzip htop ifupdown init iptables iputils-ping irqbalance isc-dhcp-client less libraspberrypi-bin libraspberrypi0 make net-tools nmap ntpdate openbsd-inetd openssh-client openssh-server pi-bluetooth rpi-update rsync ssh sshfs sudo systemd traceroute unzip vim wget wireless-tools wpasupplicant xz-utils zip

# Do not change, only override in config.mk
WIFI-SSID = 
WIFI-PASS = 

include config.mk

config.mk: config.example
	cp -n "$<" "$@"

raspi_root:
	btrfs subvolume create "$@" || mkdir "$@"
	mkdir -p "$@/usr/bin"
	chmod 755 -R "$@/"
	cp -p "/usr/bin/qemu-arm-static" "$@/usr/bin/"
	debootstrap --keyring=./raspbian-archive-keyring.gpg \
		--arch=armhf --variant=minbase \
		stretch "$@/" "${BOOTSTRAP}"

raspi_root/: raspi_root .FORCE
	printf '${SOURCES}' >$@/etc/apt/sources.list
	-chroot "$@" apt-key add - <./raspberrypi-archive-keyring.gpg
	-cp /etc/resolv.conf "$@etc/"
	-chroot "$@" sh -c 'apt-mark showmanual |xargs apt-mark auto'
	-chroot "$@" apt-get update
	chroot "$@" ln -sf /bin/true /usr/local/sbin/invoke-rc.d
	chroot "$@" apt-get --yes install ${PACKAGES}
	chroot "$@" apt-get --yes --auto-remove purge
	chroot "$@" apt-get --yes --auto-remove upgrade
	chroot "$@" rpi-update || [ -f "$@/boot/bootcode.bin" ]
	-[ -d "$@/boot.bak/" ] && rm -r "$@/boot.bak/"
	sync
	chroot "$@" apt-get clean
	chroot "$@" rm /usr/local/sbin/invoke-rc.d
	touch "$@"

id_rsa.pub:
	ssh-keygen -b 2048 -t rsa -N '' -f id_rsa

files/etc/network/interfaces.d/wifi: wifi.tmpl
	sed 's;#WIFI-SSID#;${WIFI-SSID};; s;#WIFI-PASS#;${WIFI-PASS};;' <'$<' >'$@'
	chmod 644 '$@'

files/root/.ssh/authorized_keys: id_rsa.pub
	mkdir -p files/root/.ssh/
	cat '$<' >>'$@'
	chmod 700 files/root/ files/root/.ssh/
	chmod 600 '$@'

include gummikraken.mk

raspi.img: raspi_root/ files/ partitions files/root/.ssh/authorized_keys files/etc/network/interfaces.d/wifi files/srv/gummikraken/
	-rmdir "$@.mnt"
	mkdir "$@.mnt"  # fail receipe if dir is nonempty
	dd bs=1M count=0 seek=1024 of="$@"  # set up sparse file
	sfdisk "$@" <partitions
	lo=$$(losetup -f); image='$@'; \
	start=$$(sfdisk --dump "$$image" |sed -rn 's;^.*start= *([0-9]+),.*type=83;\1;p'); \
	size=$$(sfdisk --dump "$$image" |sed -rn 's;^.*size= *([0-9]+),.*type=83;\1;p'); \
	losetup -o $$((start * 512)) --sizelimit $$((size * 512)) "$${lo}" "$$image" && \
	mkfs.ext4 -F "$$lo" && mount -t ext4 "$$lo" "$@.mnt/";
	mkdir "$@.mnt/boot"
	lo=$$(losetup -f); image='$@'; \
	start=$$(sfdisk --dump "$$image" |sed -rn 's;^.*start= *([0-9]+),.*type=c;\1;p'); \
	size=$$(sfdisk --dump "$$image" |sed -rn 's;^.*size= *([0-9]+),.*type=c;\1;p'); \
	losetup -o $$((start * 512)) --sizelimit $$((size * 512)) "$${lo}" "$$image" && \
	mkfs.fat -F 32 -n boot "$$lo" && mount -t vfat "$$lo" "$@.mnt/boot";
	cp -a "raspi_root/." "files/." "$@.mnt/"
	umount "$@.mnt/boot/" "$@.mnt/"
	losetup -a |sed -rn '/$@/{s;^([^:]+):.*$$;\1;p;q}' |xargs losetup -d
	losetup -a |sed -rn '/$@/{s;^([^:]+):.*$$;\1;p;q}' |xargs losetup -d
	rmdir "$@.mnt/"
