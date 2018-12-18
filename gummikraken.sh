#!/bin/sh

data="$1"
fieldname="$2"

case $fieldname in
       ekg) field=1 freq=1   ;;
     pulse) field=2 freq=1   ;;
      temp) field=3 freq=15  ;;
       oxy) field=4 freq=15  ;;
     heart) field=5 freq=20  ;;
   systole) field=6 freq=100 ;;
  diastole) field=7 freq=100 ;;
         *) exit 1 ;;
esac

while :; do
  sed -rn '/^e.*k$/{y;estohydk;        ;;p;}' "$data"
done \
| while read -r line; do printf %s\\n "$line"; sleep .0097; done \
| sed -urn "1~${freq}s;^([0-9]* ){${field}}([0-9]+).*$;${fieldname} \2;p"
