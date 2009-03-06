#!/bin/sh
#
#  Customise the distribution post-install.
#

prefix=$1

if [ ! -d "${prefix}" ]; then
  echo "Serious error - the named directory doesn't exist."
  exit
fi

# There's no pre-existing /dev/zero nor is there one from the packages that are already unpacked.
echo "  Creating devices in /dev"
if ! [ -e "${prefix}/dev/zero" ]; then
    mknod -m 666 "${prefix}/dev/zero" c 1 5
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
echo "  Mounting /proc"
if [ ! -d "${prefix}/proc" ]; then
    mkdir -p "${prefix}/proc"
fi
mount -o bind /proc ${prefix}/proc

echo "  Bootstrapping zypper"
chroot ${prefix} /sbin/ldconfig
chroot ${prefix} /usr/bin/zypper -n --no-gpg-checks install zypper      2>/dev/null
chroot ${prefix} /usr/bin/zypper -n --no-gpg-checks install vim-minimal 2>/dev/null
chroot ${prefix} /usr/bin/zypper -n --no-gpg-checks install dhclient    2>/dev/null
chroot ${prefix} /usr/bin/zypper -n --no-gpg-checks update              2>/dev/null


#
#  5.  Clean up
#
echo "  Cleaning up"
chroot ${prefix} /usr/bin/zypper clean

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
