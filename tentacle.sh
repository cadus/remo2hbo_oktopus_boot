#!/bin/sh

field="$1"

ncat localhost 8200 |cut -d\  -f${field}
