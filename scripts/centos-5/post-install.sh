#!/bin/sh
#
#


prefix=$1

if [ ! -d "${prefix}" ]; then
  echo "Serious error - the named directory doesn't exist."
  exit
fi


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
chroot ${prefix} /usr/bin/yum -y install yum         2>/dev/null
chroot ${prefix} /usr/bin/yum -y install vim-minimal 2>/dev/null
chroot ${prefix} /usr/bin/yum -y install dhclient    2>/dev/null

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
for i in ${prefix}/*.rpm; do
    rm -f $i
done
find ${prefix} -name '*.rpmorig' -delete
find ${prefix} -name '*.rpmnew' -delete

# Install modprobe
if [ -e "${prefix}/etc/modprobe.d/modprobe.conf.dist" ]; then
    cp  "${prefix}/etc/modprobe.d/modprobe.conf.dist" "${prefix}/etc/modprobe.conf"
fi
