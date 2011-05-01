#!/bin/sh
#
#


prefix=$1

if [ ! -d "${prefix}" ]; then
  echo "Serious error - the named directory doesn't exist."
  exit
fi

# rpm's can now be removed
rm -f ${prefix}/*.rpm

#
#  BUGFIX:
#
echo "BUGFIX"
mkdir -p ${prefix}/usr/lib/python2.4/site-packages/urlgrabber.skx
for i in ${prefix}/usr/lib/python2.4/site-packages/urlgrabber/keepalive.*; do
    mv $i ${prefix}/usr/lib/python2.4/site-packages/urlgrabber.skx/
done

#
#  Run "yum install yum".
#
echo "  Bootstrapping yum"
chroot ${prefix} /usr/bin/yum -y install yum vim-minimal dhclient 2>/dev/null

#
#  make 'passwd' work.
#
echo "  Authfix"
chroot ${prefix} /usr/bin/yum -y install authconfig
chroot ${prefix} /usr/bin/authconfig --enableshadow --update

#
#  5.  Clean up
#
echo "  Cleaning up"
chroot ${prefix} /usr/bin/yum clean all
umount ${prefix}/proc
umount ${prefix}/sys


#
#  6.  Remove the .rpm files from the prefix root.
#
echo "  Final tidy..."
find ${prefix} -name '*.rpmorig' -delete
find ${prefix} -name '*.rpmnew' -delete

# Install modprobe
if [ -e "${prefix}/etc/modprobe.d/modprobe.conf.dist" ]; then
    cp  "${prefix}/etc/modprobe.d/modprobe.conf.dist" "${prefix}/etc/modprobe.conf"
fi
