#!/bin/sh

sock=/tmp/oktopus.sock

rm "$sock"

( cd "${0%/*}/"
  for n in ./sensor_*.sh; do
    $n &
  done
  for n in ekg pulse oxygen heartrate systole diastole; do
    ./gummikraken.sh ./gummikraken.data $n &
  done
) | teesock "$sock" &

for n in 1 2 3 4 5 6 7 8 9 0; do [ ! -S "$sock" ] && sleep 1; done
chmod a+rw "$sock"
