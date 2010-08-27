#!/bin/sh
#
#  Customise the distribution post-install.
#



prefix=$1

if [ ! -d "${prefix}" ]; then
  echo "Serious error - the named directory doesn't exist."
  exit
fi



#
#  2.  Copy the cached .RPM files into the yum directory, so that
#     yum doesn't need to make them again.
#
echo "  Setting up YUM cache"
if [ ! -d ${prefix}/var/cache/yum/core/packages/ ]; then
    mkdir -p ${prefix}/var/cache/yum/core/packages/
fi
if [ ! -d ${prefix}/var/cache/yum/updates-released/packages/ ]; then
    mkdir -p ${prefix}/var/cache/yum/updates-released/packages/
fi

for i in ${prefix}/*.rpm ; do
    cp $i ${prefix}/var/cache/yum/core/packages/
    cp $i ${prefix}/var/cache/yum/updates-released/packages/
done



#
#  3.  Ensure that Yum has a working configuration file.
#
arch=i386
if [ $ARCH = "amd64" ] ; then
    arch=x86_64
fi

echo "  Creating yum.conf"
cat > ${prefix}/etc/yum.conf <<EOF
[main]
cachedir=/var/cache/yum
debuglevel=1
reposdir=/dev/null
logfile=/var/log/yum.log
retries=20
obsoletes=1
gpgcheck=0
assumeyes=1

# repos

[core]
name=core
mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=core-6&arch=$arch

[updates-released]
name=updates
mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-fc6&arch=$arch
EOF


#
#  4.  Run "yum install yum".
#
echo "  Bootstrapping yum"
chroot ${prefix} /sbin/ldconfig
chroot ${prefix} /usr/bin/yum -y install yum         2>/dev/null
chroot ${prefix} /usr/bin/yum -y install vim-minimal 2>/dev/null
chroot ${prefix} /usr/bin/yum -y install dhclient    2>/dev/null


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
