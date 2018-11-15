#!/bin/sh

data="$1"

while :; do
  sed -rn '/^e.*k$/{y;estohydk;        ;;p;}' "$data" \
  | while read line; do
    printf %s\\n "$line"
    sleep .0097
  done
done
