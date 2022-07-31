#!/bin/bash

# Instructions extracted from the Linux from Scratch book:
# Copyright © 1999-2022 Gerard Beekmans
#
# Instructions extracted from the Beyond Linux from Scratch Book:
# Copyright © 1999-2022 The BLFS Development Team
#
# Debian packaging code Copyright © 2022 Alec Bloss
#
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Extract the source archive
tar xvf dhcp-4.4.2-P1.orig.tar.gz

# Change directory to source
cd dhcp-4.4.2-P1

# GCC >=10 fix
sed -i '/o.*dhcp_type/d' server/mdb.c &&
sed -r '/u.*(local|remote)_port/d'    \
    -i client/dhclient.c              \
       relay/dhcrelay.c

# Configure and compile package - server and client compiled at the same time - DOES NOT support parallel build!
( export CFLAGS="${CFLAGS:--g -O2} -Wall -fno-strict-aliasing                 \
        -D_PATH_DHCLIENT_SCRIPT='\"/usr/sbin/dhclient-script\"'     \
        -D_PATH_DHCPD_CONF='\"/etc/dhcp/dhcpd.conf\"'               \
        -D_PATH_DHCLIENT_CONF='\"/etc/dhcp/dhclient.conf\"'"        &&

./configure --prefix=/usr                                           \
            --sysconfdir=/etc/dhcp                                  \
            --localstatedir=/var                                    \
            --with-srv-lease-file=/var/lib/dhcpd/dhcpd.leases       \
            --with-srv6-lease-file=/var/lib/dhcpd/dhcpd6.leases     \
            --with-cli-lease-file=/var/lib/dhclient/dhclient.leases \
            --with-cli6-lease-file=/var/lib/dhclient/dhclient6.leases
) &&
make -j1

# Install client to package-client directory
unset workdir
unset workdir1
workdir1=`pwd`
cd ..
workdir=`pwd`
cd $workdir1
make DESTDIR=$workdir/package-client -C client install
install -v -m755 client/scripts/linux $workdir/package-client/usr/sbin/dhclient-script

install -vdm755 $workdir/package-client/etc/dhcp &&
cat > $workdir/package-client/etc/dhcp/dhclient.conf << "EOF"
# Begin /etc/dhcp/dhclient.conf
#
# Basic dhclient.conf(5)

#prepend domain-name-servers 127.0.0.1;
request subnet-mask, broadcast-address, time-offset, routers,
        domain-name, domain-name-servers, domain-search, host-name,
        netbios-name-servers, netbios-scope, interface-mtu,
        ntp-servers;
require subnet-mask, domain-name-servers;
#timeout 60;
#retry 60;
#reboot 10;
#select-timeout 5;
#initial-interval 2;

# End /etc/dhcp/dhclient.conf
EOF

install -v -dm 755 $workdir/package-client/var/lib/dhclient

# Install server to package-server directory
make DESTDIR=$workdir/package-server -C server install

install -vdm755 $workdir/package-server/etc/dhcp

cat > $workdir/package-server/etc/dhcp/dhcpd.conf << "EOF"
# Begin /etc/dhcp/dhcpd.conf
#
# Example dhcpd.conf(5)

# Use this to enable / disable dynamic dns updates globally.
ddns-update-style none;

# option definitions common to all supported networks...
option domain-name "example.org";
option domain-name-servers ns1.example.org, ns2.example.org;

default-lease-time 600;
max-lease-time 7200;

# This is a very basic subnet declaration.
subnet 10.254.239.0 netmask 255.255.255.224 {
  range 10.254.239.10 10.254.239.20;
  option routers rtr-239-0-1.example.org, rtr-239-0-2.example.org;
}

# End /etc/dhcp/dhcpd.conf
EOF

install -v -dm 755 $workdir/package-server/var/lib/dhcpd

# Build the debian packages and rename them correctly.
cd ../
dpkg-deb --build package-client
mv package-client.deb dhclient_4.4.2_amd64.deb
dpkg-deb --build package-server
mv package-server.deb dhcpd_4.4.2_amd64.deb