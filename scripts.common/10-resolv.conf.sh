#!/bin/sh
#
#  Ensure the chroot has an /etc/resolv.conf file.
#
# Steve
# --


#
#  Get the root of the chroot.
#
prefix=$1

#
#  Ensure it exists.
#
if [ ! -d "${prefix}" ]; then
  echo "Serious error - the named directory doesn't exist."
  exit
fi

echo "  Creating resolv.conf"
if [ ! -d "${prefix}/etc/" ]; then
    mkdir -p "${prefix}/etc/"
fi

cp /etc/resolv.conf "${prefix}/etc/"

