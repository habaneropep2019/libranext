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
tar xvf gettext-0.21.orig.tar.xz

# Change directory to source
cd gettext-0.21

# Configure and compile package
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.21
make

# Install to package directory
unset workdir
unset workdir1
workdir1=`pwd`
cd ..
workdir=`pwd`
cd $workdir1
make DESTDIR=$workdir/package install
chmod -v 0755 $workdir/package/usr/lib/preloadable_libintl.so

# Remove info file so we can manage it with maintainer scripts

cd $workdir/package/usr/share/info
rm dir
cd $workdir1

# Build the debian package and rename it correctly.
cd ../
dpkg-deb --build package
mv package.deb gettext_0.21_amd64.deb