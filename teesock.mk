teesock/teesock.arm: teesock/teesock.c teesock/Makefile
	make -C "$(dir $@)" "$(notdir $@)"
	chmod 755 "$@"

files/usr/local/bin/teesock: teesock/teesock.arm
	mkdir -p files/usr/local/bin
	chmod 755 files/usr/ files/usr/local/ files/usr/local/bin/
	cp -av "$<" "$@"

raspi.img: files/usr/local/bin/teesock
