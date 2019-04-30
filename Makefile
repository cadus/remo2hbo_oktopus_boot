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
deb	http://raspbian.raspberrypi.org/raspbian stretch main non-free firmware rpi
deb	http://archive.raspberrypi.org/debian stretch main
endef

PACKAGES := apt bluez bluez-firmware bluez-tools btrfs-tools busybox-static bzip2 ca-certificates cron debian-archive-keyring deborphan firmware-brcm80211 firmware-linux-free firmware-misc-nonfree gzip htop ifupdown init iputils-ping irqbalance isc-dhcp-client less libraspberrypi-bin libraspberrypi0 make net-tools nmap ntpdate openssh-client openssh-server pi-bluetooth psmisc raspberrypi-bootloader raspberrypi-kernel rsync ssh sshfs sudo systemd traceroute unzip vim wget wireless-tools wpasupplicant xz-utils zip
PACKAGES := ${PACKAGES} bridge-utils dnsmasq iptables make nmap openbsd-inetd xserver-xorg-video-fbturbo xserver-xorg nodm chromium-browser

IMGFILE = raspi.img

${IMGFILE}:

config.mk: config.example
	cp -n "$<" "$@"
include config.mk

.PHONY: imgfile imgmount root_copy norecommends apt_keys wifi_cfg ssh_key busybox

export SOURCES
export WIFI_CFG

raspi_root:
	btrfs subvolume create "$@" || mkdir "$@"
	mkdir -p "$@/usr/bin"
	chmod 755 -R "$@/"
	cp -p "/usr/bin/qemu-arm-static" "$@/usr/bin/"
	debootstrap --keyring=./raspbian-archive-keyring.gpg \
		--arch=armhf --variant=minbase \
		stretch "$@/" "${BOOTSTRAP}"

norecommends: raspi_root/etc/apt/apt.conf.d/10norecommends
raspi_root/etc/apt/apt.conf.d/10norecommends: raspi_root
	mkdir -p "$</etc/apt/apt.conf.d/"
	printf 'APT::Install-Recommends "false";\n' >"$@"
	chmod 644 "$@"

apt_keys: raspi_root
	-chroot "$<" apt-key add - <./raspbian-archive-keyring.gpg
	-chroot "$<" apt-key add - <./raspberrypi-archive-keyring.gpg
	-chroot "$<" apt-key add - <./debian-archive-stretch-stable.gpg

raspi_root/: raspi_root norecommends apt_keys .FORCE
	printf %s "$$SOURCES" >$@/etc/apt/sources.list
	-cp /etc/resolv.conf "$@etc/"
	-chroot "$@" sh -c 'apt-mark showmanual |xargs apt-mark auto'
	-chroot "$@" apt-get update
	chroot "$@" ln -sf /bin/true /usr/local/sbin/invoke-rc.d
	chroot "$@" apt-get --yes install ${PACKAGES}
	chroot "$@" apt-get --yes --auto-remove purge
	-chroot "$@" apt-get --yes --auto-remove upgrade
	chroot "$@" apt-get clean
	chroot "$@" rm /usr/local/sbin/invoke-rc.d
	touch "$@"

imgfile: raspi_root/  # do not set up image file before chroot
imgfile: partitions
	dd bs=1M count=0 seek=1280 of="${IMGFILE}"  # set up sparse file
	sfdisk "${IMGFILE}" <partitions

imgmount: imgfile
	-rmdir "$@"
	mkdir "$@"  # fail receipe if dir is nonempty
	lo=$$(losetup -f); image='${IMGFILE}'; \
	start=$$(sfdisk --dump "$$image" |sed -rn 's;^.*start= *([0-9]+),.*type=83;\1;p'); \
	size=$$(sfdisk --dump "$$image" |sed -rn 's;^.*size= *([0-9]+),.*type=83;\1;p'); \
	losetup -o $$((start * 512)) --sizelimit $$((size * 512)) "$${lo}" "$$image" && \
	mkfs.ext4 -F "$$lo" && mount -t ext4 "$$lo" "$@/";
	mkdir "$@/boot"
	lo=$$(losetup -f); image='${IMGFILE}'; \
	start=$$(sfdisk --dump "$$image" |sed -rn 's;^.*start= *([0-9]+),.*type=c;\1;p'); \
	size=$$(sfdisk --dump "$$image" |sed -rn 's;^.*size= *([0-9]+),.*type=c;\1;p'); \
	losetup -o $$((start * 512)) --sizelimit $$((size * 512)) "$${lo}" "$$image" && \
	mkfs.fat -F 32 -n boot "$$lo" && mount -t vfat "$$lo" "$@/boot";

root_copy: imgmount raspi_root/ files/
	cp -a "raspi_root/." "files/." "$</"

id_rsa.pub:
	ssh-keygen -b 2048 -t rsa -N '' -f id_rsa

ssh_key: imgmount root_copy id_rsa.pub
	mkdir -p "$</root/.ssh/"
	cat id_rsa.pub >>"$</root/.ssh/authorized_keys"
	chmod 700 "$</root" "$</root/.ssh"
	chmod 600 "$</root/.ssh/authorized_keys"

wifi_cfg: imgmount root_copy
	printf '%s\n' "$$WIFI_CFG" >"$</etc/network/interfaces.d/wifi"
	chmod 644 "$</etc/network/interfaces.d/wifi"

busybox: imgmount root_copy
	mkdir -p -m 755 "$</opt/busybox"
	chroot "$<" busybox --install -s /opt/busybox

${IMGFILE}: imgmount root_copy wifi_cfg ssh_key busybox
	umount "$</boot/" "$</"
	losetup -a |sed -En '/${IMGFILE}/{s;^([^:]+):.*$$;\1;p;q}' |xargs losetup -d
	losetup -a |sed -En '/${IMGFILE}/{s;^([^:]+):.*$$;\1;p;q}' |xargs losetup -d
	rmdir "$</"
