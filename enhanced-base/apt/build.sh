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
tar xvf apt_2.5.1.orig.tar.xz

# Change directory to source
cd apt-2.5.1

# Configure and compile package
mkdir build
cd build

cmake -DWITH_DOC:BOOL=OFF -DWITH_DOC_DOXYGEN:BOOL=OFF -DWITH_DOC_EXAMPLES:BOOL=OFF -DWITH_DOC_GUIDES:BOOL=OFF -DWITH_DOC_MANPAGES:BOOL=ON -DWITH_TESTS:BOOL=OFF -DCACHE_DIR:PATH=/var/cache/apt -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCONF_DIR:PATH=/etc/apt -DLIBEXEC_DIR:PATH=/usr/libexec/apt -DLOG_DIR:PATH=/var/log/apt -DSTATE_DIR:PATH=/var/lib/apt -DBASH_COMPLETION_DIR:PATH=/usr/share/bash-completion/completions ../
make

# Install to package directory
unset workdir
unset workdir1
workdir1=`pwd`
cd ../..
workdir=`pwd`
cd $workdir1
make DESTDIR=$workdir/package install

# Build the debian package and rename it correctly.
cd ../..
dpkg-deb --build package
mv package.deb apt_2.5.1_amd64.deb