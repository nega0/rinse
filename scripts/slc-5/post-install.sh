#!/bin/sh
#
#  post-install.sh
#  Scientific Linux CERN (SLC5)

prefix=$1

if [ ! -d "${prefix}" ]; then
  echo "Serious error - the named directory doesn't exist."
  exit
fi

# rpm's can now be removed
rm -f ${prefix}/*.rpm

touch ${prefix}/etc/mtab

echo "  Bootstrapping yum"
chroot ${prefix} /usr/bin/yum -y install yum vim-minimal dhclient 2>/dev/null

echo "  cleaning up..."
chroot ${prefix} /usr/bin/yum clean all 
umount ${prefix}/proc
umount ${prefix}/sys

# Install modprobe
if [ -e "${prefix}/etc/modprobe.d/modprobe.conf.dist" ]; then
    cp  "${prefix}/etc/modprobe.d/modprobe.conf.dist" "${prefix}/etc/modprobe.conf"
fi

echo "  post-install.sh : done."
