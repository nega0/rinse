#!/bin/sh
#
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
#  2.  Setup yum.conf
#
cat >>${prefix}/etc/yum.conf <<EOF
[base]
name=CentOS-5 - Base
mirrorlist=http://mirrorlist.centos.org/?release=5&arch=i386&repo=os
baseurl=http://mirror.centos.org/centos/5/os/i386/
gpgcheck=0
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-centos4
priority=1
protect=1

#released updates 
[update]
name=CentOS-5 - Updates
mirrorlist=http://mirrorlist.centos.org/?release=5&arch=i386&repo=updates
baseurl=http://mirror.centos.org/centos/5/updates/i386/
gpgcheck=0
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-centos4
priority=1
protect=1

#packages used/produced in the build but not released
[addons]
name=CentOS-5 - Addons
mirrorlist=http://mirrorlist.centos.org/?release=5&arch=i386&repo=addons
baseurl=http://mirror.centos.org/centos/5/addons/i386/
gpgcheck=0
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-centos4
priority=1
protect=1

#additional packages that may be useful
[extras]
name=CentOS-5 - Extras
mirrorlist=http://mirrorlist.centos.org/?release=5&arch=i386&repo=extras
baseurl=http://mirror.centos.org/centos/5/extras/i386/
gpgcheck=0
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-centos4
priority=1
protect=1

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-5 - Plus
mirrorlist=http://mirrorlist.centos.org/?release=5&arch=i386&repo=centosplus
baseurl=http://mirror.centos.org/centos/5/centosplus/i386/
gpgcheck=0
enabled=0
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-centos4
priority=2
protect=1

#contrib - packages by Centos Users
[contrib]
name=CentOS-5 - Contrib
mirrorlist=http://mirrorlist.centos.org/?release=5&arch=i386&repo=contrib
baseurl=http://mirror.centos.org/centos/5/contrib/i386/
gpgcheck=0
enabled=0
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-centos4
priority=2
protect=1

EOF


#
#  3.5 BUGFIX:
echo "BUGFIX"
mkdir -p ${prefix}usr/lib/python2.4/site-packages/urlgrabber.skx
for i in ${prefix}/usr/lib/python2.4/site-packages/urlgrabber/keepalive.*; do
    mv $i ${prefix}usr/lib/python2.4/site-packages/urlgrabber.skx/
done

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
chroot ${prefix} /usr/bin/yum -y install yum passwd 2>/dev/null


#
#  5.  Clean up
#
echo "  Cleaing up"
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
