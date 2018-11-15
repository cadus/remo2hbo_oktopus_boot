files/srv/gummikraken/: gummikraken/
	mkdir -p "$@"
	cp -av "$</." "$@/."
	cp gummikraken/inetd.conf files/etc/inetd.conf
