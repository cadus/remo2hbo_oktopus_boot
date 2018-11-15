#!/bin/sh

field="$1"

nc localhost 8200 |cut -d\\  -f${field}
