#!/bin/sh
#
#


prefix=$1

if [ ! -d "${prefix}" ]; then
  echo "Serious error - the named directory doesn't exist."
  exit
fi

arch=i386
if [ $ARCH == "amd64" ] ; then
       arch=x86_64
fi


#
#  1.  Make sure there is a resolv.conf file present, such that
#     DNS lookups succeed.
#
echo "  Creating resolv.conf"
if [ ! -d "${prefix}/etc/" ]; then
    mkdir -p "${prefix}/etc/"
fi
cp /etc/resolv.conf "${prefix}/etc/"

#
#  3.5 BUGFIX:
echo "BUGFIX"
mkdir -p ${prefix}/usr/lib/python2.4/site-packages/urlgrabber.skx
for i in ${prefix}/usr/lib/python2.4/site-packages/urlgrabber/keepalive.*; do
    mv $i ${prefix}/usr/lib/python2.4/site-packages/urlgrabber.skx/
done

# 3.6 BUGFIX: yumrepo
echo "BUGFIX: yumrepo"
chroot ${prefix} sed -i s/\$releasever/5/g /etc/yum.repos.d/CentOS-Base.repo
chroot ${prefix} sed -i s/\$basearch/$arch/g /etc/yum.repos.d/CentOS-Base.repo
#
#
#  4.  Run "yum install yum".
#
echo "  Mounting /proc"
if [ ! -d "${prefix}/proc" ]; then
    mkdir -p "${prefix}/proc"
fi
mount -o bind /proc ${prefix}/proc

echo "  Bootstrapping yum"
chroot ${prefix} /usr/bin/yum -y install yum         2>/dev/null
chroot ${prefix} /usr/bin/yum -y install vim-minimal 2>/dev/null
chroot ${prefix} /usr/bin/yum -y install dhclient    2>/dev/null

#
#  4.5 make 'passwd' work.
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


#
#  6.  Remove the .rpm files from the prefix root.
#
echo "  Final tidy..."
for i in ${prefix}/*.rpm; do
    rm -f $i
done
find ${prefix} -name '*.rpmorig' -delete
find ${prefix} -name '*.rpmnew' -delete
