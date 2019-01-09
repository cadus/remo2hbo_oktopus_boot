# Oktopus Boot

Generator for Oktopus boot media.

## Purpose
The Oktopus sensor computer displays data on devices connected via Bluetooth. To enable this it opens a Bluetooth network access point. This AP allows connections by any device. To enable IP connectivity a DHCP server will be started on Oktopus. Oktopus identifies itself as an internet gateway to connecting devices. All attempts by those clients to connect to any websites will be directed to the local sensor display. This is enabled by a "fake" DNS server running on Oktopus, which resolves all domain names to the sensor computer itself.

In order to provide the necessary combination of Bluetooth, DHCP, and DNS settings, we provide a custom operating system image. This git repository contains the scripts and configuration files to assemble this image.

## Requirements and Compatibility:
The build system must support Linux style loopback devices. The script as it is will only run on Linux OSes, and it strictly requires the `losetup` utility from the GNU userland package. In addition the main script is a GNU style makefile. This software will _not_ work on BSD or Mac OS X, without modification. It will also not work on `busybox` based Linux OSes.

The Raspberry environment is configured via ARM CPU emulation using qemu. A static qemu binary for ARM emulation must be provided, as well as the accompanying binfmt support in the kernel.

Required Programs are:
 * a Linux Kernel with loop support (almost always available)
 * `make` (GNU flavour)
 * `losetup` (GNU flavour)
 * `qemu-arm-static` (e.g. from the `qemu-user-static` Debian package)
 *  a C compiler for the ARM platform (i.e. `gcc-arm-linux-gnueabi`, see submodule `teesock`)
 * `mkfs.ext4`
 * `mkfs.fat`
 * `sfdisk`
 * `debootstrap`
 * `ssh-keygen` (optional)

`debootstrap` is available in all Debian derivatives, including Ubuntu. It can be installed in some Non-Debian distributions as well.

## Usage
The script must be run as root. The target is `raspi.img`. I.e. you should run (as root):

    make raspi.img

The resulting `raspi.img` file can be written to an SD-Card using `dd`. And a Raspberry Pi can be booted from this SD-Card.

Some configuration options can be set in `config.mk`. See `config.example` as a template, but do not edit `config.example`directly, as it is tracked by git.
`config.mk` is particularly useful to set up an APT-Proxy, and to set up Wifi credentials. If Wifi credentials are set up, the Oktopus computer will attempt to connect to the specified wireless network to provide SSH access. Network configuration on the Wifi network is derived via DHCP, the Oktopus DHCP server will not interfere with the wifi network.

## Log in on the Sensor Computer
Oktopus provides only a root login using SSH key authentication. There is no user account, no `sudo`, and no password login. You can provide an SSH public key before staring the build, which can later be used for the root login. In order to do this you just need to copy your public key to `id_rsa.pub` in the root folder of this repository. Note that even EC, or DSA keys should be named `id_rsa.pub`.
If you do not provide your own SSH key, the build script will conveniently generate one. You can then later login to Oktopus, by typing:

    ssh -i id_rsa root@oktopus

## Function outline

### OS Image
The Makefile uses `debootstrap` to set up a Raspbian environment. Package signatures will be verified. Operations within the Raspbian environment are performed using `qemu`. Thus building on a x86 host platform is possible. The environment is then copied to an image file using loopback mounting. The `files` directory contains an overlay of Raspbian config files, which are copied into the image file at this stage. Since this happens at _image_ creation, the debootstrapped root _directory_ is modified as little as possible. 

The list of raspbian packages which are installed in the chroot environmant can be extended in `config.mk`.

### Bluetooth and Wifi Networking
DHCP and DNS services on Oktopus are provided by `dnsmasq`. Bluetooth networking is provided by the regular Linux Bluetooth stack using hci, bridge, and ip/ifup utilities. All attempts to connect to the Bluetooth network ap are trusted automatically, this is facilitated by a shell loop in (`files/`)`etc/rc.local` (autotrust is not otherwise provided by the Bluetooth stack).
As a matter of convenience during testing and debugging the sensor computer can also join an existing Wifi network. Wifi credentials can be provided in `config.mk`. Because Oktopus will not provide DHCP and DNS on Wifi, the name resolution for Oktopus services will not work on Wifi and the sensor webapp may not be usable. Only Bluetooth networking is intended for this kind of operation.

### Sensor readout and Webapp

> The sensor application is currently under development. The `gummikraken` submodule provides virtual sensors with simulation data. Gummikraken will be gradually replaced by working sensor drivers.

> The display application (oktopus_frontend) is developed as a separate project. See its respective repository for a detailed documentation.

Also see git submodules:
  * gummikraken (to be removed)
  * teesock
  * gummikraken/oktopus_frontend (submodule to be moved to the main repo)

The sensor application resides under `/srv/` in the generated system image. Each sensor is read periodically by a distinct program. Each sensor program provides sensor readout on stdout in a short time interval of its own choosing. All sensor programs are launched in parallel by `hatch.sh`. The sensor data is accumulated and provided on a Unix socket (`/tmp/oktopus.sock`) by the program `teesock`. Each connection to this socket will yield a copy of the current sensor stream.

The display application is served over HTTP by the busybox httpd, which is launched from inetd. The display reads the sensor data as an HTTP Event Stream from port 8200 (Okt-Two-pus ;-). The Event Stream is generated from the sensor stream on the aforementioned Unix socket. Conversion of the seonsor readout to the HTTP Event Stream format is done by `tentacles.sh`, which is also launched via inetd.

## ToDo
 * include the sensor driver and utilities (so far: temperature, ...)
 * ~~include the display application~~ (done)
 * ~~provide the display application via web server~~ (done)
 * possibly counter DNS rebind protection by identifying as gateway and redirect via `iptables` (may not be necessary)

## Legal
This program was originally developed on behalf of the Hochschule für Technik und Wirtschaft Berlin. The program is licensed under the GNU Affero General Public License. See LICENSE.TXT for details.
