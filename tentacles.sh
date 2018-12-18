#!/bin/sh

CR="$(printf \\r)"

read METHOD LOCATION PROTOCOL
while read name value; do
  [ ! "${name%$CR}" ] && break
done

printf 'HTTP/1.1 200 OK\r\n'
printf '%s: %s\r\n' \
  Connection close \
  Access-Control-Allow-Origin '*' \
  Content-Type text/event-stream
printf '\r\n'

ncat -U /tmp/oktopus.sock \
| while read event value; do
  printf '
event: %s
data: %i
' "$event" "$value"
done
