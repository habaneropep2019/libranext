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
tar xvf tcl8.6.12-src.orig.tar.gz

# Change directory to source
cd tcl8.6.12

# Configure and compile package
tar -xf ../tcl8.6.12-html.orig.tar.gz --strip-components=1

SRCDIR=$(pwd)
cd unix
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            $([ "$(uname -m)" = x86_64 ] && echo --enable-64bit)
make

sed -e "s|$SRCDIR/unix|/usr/lib|" \
    -e "s|$SRCDIR|/usr/include|"  \
    -i tclConfig.sh

sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.3|/usr/lib/tdbc1.1.3|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.3/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/tdbc1.1.3/library|/usr/lib/tcl8.6|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.3|/usr/include|"            \
    -i pkgs/tdbc1.1.3/tdbcConfig.sh

sed -e "s|$SRCDIR/unix/pkgs/itcl4.2.2|/usr/lib/itcl4.2.2|" \
    -e "s|$SRCDIR/pkgs/itcl4.2.2/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/itcl4.2.2|/usr/include|"            \
    -i pkgs/itcl4.2.2/itclConfig.sh

unset SRCDIR

# Install to package directory
unset workdir
unset workdir1
workdir1=`pwd`
cd ../..
workdir=`pwd`
cd $workdir1
make DESTDIR=$workdir/package install

chmod -v u+w $workdir/package/usr/lib/libtcl8.6.so

make DESTDIR=$workdir/package install-private-headers

mv $workdir/package/usr/share/man/man3/{Thread,Tcl_Thread}.3

mkdir -v -p $workdir/package/usr/share/doc/tcl-8.6.12
cp -v -r  ../html/* $workdir/package/usr/share/doc/tcl-8.6.12

# Build the debian package and rename it correctly.
cd ../..
dpkg-deb --build package
mv package.deb tcl_8.6.12_amd64.deb