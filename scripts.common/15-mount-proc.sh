#!/bin/sh
#
#  Ensure the chroot has /proc + /sys mounted.
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

#
#  Mount /proc + /sys
#
for i in /proc /sys; do
    echo "  Mounting $i"
    if [ ! -d "${prefix}/$i" ]; then
        mkdir -p "${prefix}/$i"
    fi

    #
    #  Bind-mount
    #
    mount -o bind $i ${prefix}/${i}
done