define ws5inch_boot =
hdmi_group=2
hdmi_mode=87
hdmi_cvt=800 480 60 6 0 0 0
hdmi_drive=1

dtparam=i2c_arm=on
dtparam=spi=on
enable_uart=1
dtoverlay=ads7846,cs=1,penirq=25,penirq_pull=2,speed=50000,keep_vref_on=0,swapxy=0,pmax=255,xohms=150,xmin=200,xmax=3900,ymin=200,ymax=3900
endef
export ws5inch_boot

PACKAGES := ${PACKAGES} xserver-xorg-input-evdev xinput xinput-calibrator

.PHONY: ws5inch
${IMGFILE}: ws5inch
ws5inch: imgmount root_copy files_ws5inch/
	cp -a files_ws5inch/. "$</"
	printf %s "$$ws5inch_boot" >>"$</boot/config.txt"
	-chroot "$<" adduser local input
