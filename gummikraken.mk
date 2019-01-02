files/srv/gummikraken/: gummikraken/ sensors/ .FORCE
	mkdir -p "$@"
	cp -av "$</." sensors/. "$@/."
	chmod a+rX -R "$@"
	cp gummikraken/inetd.conf files/etc/inetd.conf
	sed -ri 's;http://[0-9\.]+:8200;http://oktopus:8200;g' "$@/oktopus_frontend/dist/bundle.js"

raspi.img: files/srv/gummikraken/
