frontend_inetd := 80	stream	tcp	nowait	nobody	/bin/busybox	httpd -i -h /srv/oktopus_frontend/
export frontend_inetd

.PHONY: frontend

${IMGFILE}: frontend
frontend: imgmount root_copy oktopus_frontend/dist/
	mkdir -p "$</srv/oktopus_frontend"
	cp -av oktopus_frontend/dist/. "$</srv/oktopus_frontend/"
	chmod a+rX -R "$</srv/oktopus_frontend/"
	printf '%s\n' "$$frontend_inetd" >>"$</etc/inetd.conf"
	sed -ri 's;http://[0-9\.]+:8200;http://oktopus:8200;g' "$</srv/oktopus_frontend/bundle.js"
	chroot "$<" useradd -s /opt/busybox/ash -m local
	chroot "$<" adduser local video
