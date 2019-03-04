#!/bin/sh

usermod -p "$(openssl passwd -1 -salt ert root)" root
useradd -m local
