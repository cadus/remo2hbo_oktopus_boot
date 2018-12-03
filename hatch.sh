#!/bin/sh

sock=/tmp/oktopus.sock

rm "$sock"

( cd "${0%/*}/"
  ./gummikraken.sh ./gummikraken.data \
  | ncat --send-only -klU "$sock"
) &

for n in 1 2 3 4 5 6 7 8 9 0; do [ ! -S "$sock" ] && sleep 1; done
chmod a+rw "$sock"
ncat -U "$sock" >/dev/null &
