teesock: teesock.c
	cc -o "$@" "$<"

teesock.arm: teesock.c
	arm-linux-gnueabihf-gcc -o "$@" "$<"
