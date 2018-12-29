#!/bin/sh

while sleep 1; do
  sed -nr 's;^.*t=([0-9]{3})[0-9]{2};temperature \1;p' /sys/bus/w1/devices/28-*/w1_slave
done
