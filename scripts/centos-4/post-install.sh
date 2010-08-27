#!/bin/sh
#
#


prefix=$1

if [ ! -d "${prefix}" ]; then
  echo "Serious error - the named directory doesn't exist."
  exit
fi



echo "  Bootstrapping yum"
chroot ${prefix} /usr/bin/yum -y install yum passwd 2>/dev/null
chroot ${prefix} /usr/bin/yum -y install vim-minimal dhclient 2>/dev/null


#
#  make 'passwd' work.
#
echo "  Authfix"
chroot ${prefix} /usr/bin/yum -y install authconfig
chroot ${prefix} /usr/bin/authconfig --enableshadow --update


#
#  Clean up
#
echo "  Cleaning up"
chroot ${prefix} /usr/bin/yum clean all
umount ${prefix}/proc
umount ${prefix}/sys


#
#  6.  Remove the .rpm files from the prefix root.
#
echo "  Final tidy..."
for i in ${prefix}/*.rpm; do
    rm -f $i
done
find ${prefix} -name '*.rpmorig' -delete
find ${prefix} -name '*.rpmnew' -delete
