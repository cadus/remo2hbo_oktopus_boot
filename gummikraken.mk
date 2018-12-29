files/srv/gummikraken/: gummikraken/ sensors/ .FORCE
	mkdir -p "$@"
	cp -av "$</." sensors/. "$@/."
	chmod a+rX -R "$@"
	cp gummikraken/inetd.conf files/etc/inetd.conf

raspi.img: files/srv/gummikraken/
