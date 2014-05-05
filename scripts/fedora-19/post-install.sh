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
#  1.  Make sure there is a resolv.conf file present, such that
#     DNS lookups succeed.
#
echo "  Creating resolv.conf"
if [ ! -d "${prefix}/etc/" ]; then
    mkdir -p "${prefix}/etc/"
fi
cp /etc/resolv.conf "${prefix}/etc/"


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

# A correct mirror URL does not contain /Packages on the end
mirror=`dirname $mirror`

echo "  Creating initial yum.conf"
cat > ${prefix}/etc/yum.conf <<EOF
[main]
reposdir=/dev/null
logfile=/var/log/yum.log

[core]
name=core
baseurl=$mirror
EOF


#
#  4.  Run "yum install yum".
#
echo "  Mounting /proc"
if [ ! -d "${prefix}/proc" ]; then
    mkdir -p "${prefix}/proc"
fi
mount -o bind /proc ${prefix}/proc

echo "  Moving /bin/, /sbin/, /lib/ to /usr/"
for dir in bin sbin lib lib64; do
    if [ -d ${prefix}/${dir} ]; then
	cp -a ${prefix}/${dir}/* ${prefix}/usr/${dir}/
	rm -rf ${prefix}/${dir}
	ln -s usr/${dir} ${prefix}/${dir}
    fi
done

echo "  Priming the yum cache"
if [ ! -d "${prefix}/var/cache/yum/core/packages/" ]; then
    mkdir -p ${prefix}/var/cache/yum/core/packages
fi
cp /var/cache/rinse/fedora-18.$ARCH/* ${prefix}/var/cache/yum/core/packages/

echo "  Bootstrapping yum"
chroot ${prefix} /usr/sbin/ldconfig
chroot ${prefix} /usr/sbin/MAKEDEV urandom
chroot ${prefix} /usr/bin/yum -y install yum         2>/dev/null
chroot ${prefix} /usr/bin/yum -y install vim-minimal 2>/dev/null
chroot ${prefix} /usr/bin/yum -y install dhclient    2>/dev/null
chroot ${prefix} /usr/bin/yum -y install rsyslog     2>/dev/null

# Can use regular repositories now
echo "  Creating final yum.conf"
cat > ${prefix}/etc/yum.conf <<EOF
[main]
logfile=/var/log/yum.log
gpgcheck=1

# PUT YOUR REPOS HERE OR IN separate files named file.repo
# in /etc/yum.repos.d
EOF


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

