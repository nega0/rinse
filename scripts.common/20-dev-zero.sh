#!/bin/sh
#
#  Ensure the chroot has /dev/zero
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
#  Ensure we have /dev
#
if [ ! -d "${prefix}/dev" ]; then
    mkdir "${prefix}/dev"
fi


#
#  Create the node
#
echo "  Creating devices in /dev"
if [ !  -e "${prefix}/dev/zero" ]; then
    mknod -m 666 "${prefix}/dev/zero" c 1 5
fi

echo "  Creating random devices in /dev"
if [ !  -e "${prefix}/dev/random" ]; then
    mknod -m 666 "${prefix}/dev/random" c 1 8
    chown root:root "${prefix}/dev/random"
fi
if [ !  -e "${prefix}/dev/urandom" ]; then
    mknod -m 666 "${prefix}/dev/urandom" c 1 9
    chown root:root "${prefix}/dev/urandom"
fi
