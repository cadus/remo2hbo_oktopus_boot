.PHONY: teesock

${IMGFILE}: teesock
teesock: imgmount root_copy teesock/teesock.arm
	mkdir -p $</usr/local/bin
	chmod 755 $</usr/ $</usr/local/ $</usr/local/bin/
	cp -av teesock/teesock.arm "$</usr/local/bin/"

teesock/teesock.arm: teesock/teesock.c teesock/Makefile
	make -C "$(dir $@)" "$(notdir $@)"
	chmod 755 "$@"
