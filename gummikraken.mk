gummikraken_inetd := 8200	stream	tcp	nowait	nobody	/srv/gummikraken/tentacles.sh	webtopus
export gummikraken_inetd

.PHONY: gummikraken

${IMGFILE}: gummikraken
gummikraken: imgmount root_copy gummikraken/ sensors/
	mkdir -p "$</srv/gummikraken"
	cp -av gummikraken/. sensors/. "$</srv/gummikraken/"
	chmod a+rX -R "$</srv/gummikraken/"
	printf '%s\n' "$$gummikraken_inetd" >>"$</etc/inetd.conf"
