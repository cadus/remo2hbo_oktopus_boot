# Oktopus Boot

Generator for Oktopus boot media.

## Purpose
The Oktopus sensor computer displays data on devices connected via Bluetooth. To enable this it opens a Bluetooth network access point. This AP allows connections by any device. To enable IP connectivity a DHCP server must be running on Oktopus. Oktopus identifies itself as an internet gateway to connecting devices. All attempts by those clients to connect to any websites will be directed to the local sensor display. This requires a "fake" DNS server running on Oktopus, which resolves all domain names to the sensor computer itself.

In order to provide the necessary combination of Bluetooth, DHCP, and DNS settings, we provide a custom operating system image. This git repository contains the scripts and configuration files to assemble this image.

## Requirements and Compatibility:
The build system must support Linux style loopback devices. The script as it is will only run on Linux OSes, and it strictly requires the `losetup` utility from the GNU userland package. In addition the main script is a GNU style makefile. This software will _not_ work on BSD or Mac OS X, without modification. It will also not work on `busybox` based Linux OSes.

The Raspberry environment is configured via ARM CPU emulation using qemu. A static qemu binary for ARM emulation must be provided, as well as the accompanying binfmt support in the kernel.

Required Programs are:
 * a Linux Kernel with loop support (almost always available)
 * `make` (GNU flavour)
 * `losetup` (GNU flavour)
 * `qemu-arm-static` (e.g. from the qemu-user-static Debian package)
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
`config.mk` is particularly useful to set up an APT-Proxy, and to set up Wifi credentials. If Wifi credentials are set up, the Oktopus computer will attempt to connect to the specified wireless network to provide SSH access.

## Logging in on the Sensor Computer
Oktopus provides only a root login using SSH key authentication. There is no user account, no `sudo`, and no password login. You can provide an SSH public key before staring the build, which can later be used for the root login. In order to do this you just need to copy your public key to `id_rsa.pub` in the root folder of this repository. Note that even a EC, or DSA keys should be named `id_rsa.pub`.
If you do not provide your own SSH key, the build script will conveniently generate one. You can then later login to Oktopus, by typing:

    ssh -i id_rsa root@oktopus

## ToDo
 * include the sensor driver and utilities
 * include the display application
 * provide the display application via web server (mockup server so far)
 * possibly counter DNS rebind protection by identifying as gateway and redirect via `iptables` (may not be necessary)
