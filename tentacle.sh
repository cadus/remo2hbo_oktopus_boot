#!/bin/sh

field="$1"

CR="$(printf \\r)"

read METHOD P PROTOCOL
while read name value; do
  [ ! "${name%$CR}" ] && break
done

printf 'HTTP/1.1 200 OK\r\n'
printf '%s: %s\r\n' \
  Connection close \
  Content-Type text/plain
printf '\r\n'

ncat localhost 8200 |cut -d\  -f${field}
