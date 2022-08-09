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
tar xvf zip30.orig.tar.gz
tar xvf zip_3.0-12.debian.tar.gz

# Change directory to source
cd zip30

# Apply patches
unset stripsl
stripsl=$(echo "$PWD" | grep -o '/' - | wc -l)
stripsl=$(($stripsl-1))
patch -p$stripsl ../debian/patches/*.patch
unset stripsl

# Configure and compile package.
make -f unix/Makefile generic_gcc

# Install to package directory
unset workdir
unset workdir1
workdir1=`pwd`
cd ..
workdir=`pwd`
cd $workdir1
make prefix=$workdir/package/usr MANDIR=$workdir/package/usr/share/man/man1 -f unix/Makefile install

# Build the debian package and rename it correctly.
cd ../
dpkg-deb --build package
mv package.deb zip_3.0-deb12_amd64.deb