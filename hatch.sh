#!/bin/sh

sock=/tmp/oktopus.sock

rm "$sock"

( cd "${0%/*}/"
  ./gummikraken.sh ./gummikraken.data \
  | ncat --send-only -klU "$sock"
) &

chmod a+rw "$sock"
ncat -U "$sock" >/dev/null &
