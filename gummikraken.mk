files/srv/gummikraken/: gummikraken/
	mkdir -p "$@"
	cp -av "$</." "$@/."
	chmod a+rX -R "$@"
	cp gummikraken/inetd.conf files/etc/inetd.conf
