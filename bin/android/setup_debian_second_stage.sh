#!/bin/bash

distro=testing
export LANG=C

/debootstrap/debootstrap --second-stage

cat <<EOF > /etc/apt/sources.list
deb http://ftp.fr.debian.org/debian/ testing main contrib non-free
deb-src http://ftp.fr.debian.org/debian/ testing main contrib non-free
EOF
apt-get update
apt-get install aptitude
aptitude update
aptitude install packages
