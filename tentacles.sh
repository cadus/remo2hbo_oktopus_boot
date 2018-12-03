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
| while read ekg pulse temp oxy heart systole diastole; do
  printf '
event: ekg
data: %i

event: pulse
data: %i

event: temperature
data: %i

event: oxygen
data: %i

event: heartrate
data: %i

event: systole
data: %i

event: diastole
data: %i
' \
  "$ekg" "$pulse" "$temp" "$oxy" "$heart" "$systole" "$diastole"
  sleep .0097
done
