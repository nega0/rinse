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
#  2.  Copy the cached .RPM files into the zypper directory, so that
#     zypper doesn't need to fetch them again.
#
echo "  Setting up zypper cache"

if [ ! -d "${prefix}/var/cache/zypp/packages/opensuse/suse/${arch}" ]; then
    mkdir -p ${prefix}/var/cache/zypp/packages/opensuse/suse/${arch}
fi
cp ${cache_dir}/${dist}.${ARCH}/* ${prefix}/var/cache/zypp/packages/opensuse/suse/${arch}


#
#  3.  Ensure that zypper has a working configuration file.
#
arch=i386
if [ $ARCH = "amd64" ] ; then
    arch=x86_64
fi

echo "  Creating zypper repo entry"
[ -d "${prefix}/etc/zypp/repos.d" ] || mkdir -p ${prefix}/etc/zypp/repos.d
cat > ${prefix}/etc/zypp/repos.d/${dist}.repo <<EOF
[opensuse]
name=${dist}
baseurl=$(dirname $(dirname ${mirror}))
enabled=1
gpgcheck=1

EOF


#
#  4.  Run "zypper install zypper".
#
# FIXME - Figure out a better way to bootstrap/prime zypper so it doesn't take so long
echo "  Bootstrapping zypper - this will take some time!"
chroot ${prefix} /sbin/ldconfig
chroot ${prefix} /bin/sh -c "/usr/bin/yes | /usr/bin/zypper sa $(dirname $(dirname ${mirror})) ${dist}"
chroot ${prefix} /bin/sh -c "/usr/bin/yes | /usr/bin/zypper install zypper"      2>/dev/null
chroot ${prefix} /bin/sh -c "/usr/bin/yes | /usr/bin/zypper install vim-minimal" 2>/dev/null
chroot ${prefix} /bin/sh -c "/usr/bin/yes | /usr/bin/zypper install dhclient"    2>/dev/null
chroot ${prefix} /bin/sh -c "/usr/bin/yes | /usr/bin/zypper update"              2>/dev/null


#
#  5.  Clean up
#
echo "  Cleaning up"
rm -f ${prefix}/var/cache/zypp/packages/opensuse/suse/${arch}/*.rpm
umount ${prefix}/proc
umount ${prefix}/sys


#
#  6.  Remove the .rpm files from the prefix root.
#
echo "  Final tidy..."
rm -f ${prefix}/*.rpm

find ${prefix} -name '*.rpmorig' -delete
find ${prefix} -name '*.rpmnew' -delete
