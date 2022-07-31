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
tar xvfj cracklib-2.9.7.orig.tar.bz2

# Change directory to source
cd cracklib-2.9.7

# Configure and compile package
sed -i '/skipping/d' util/packer.c &&

sed -i '15209 s/.*/am_cv_python_version=3.10/' configure &&

PYTHON=python3 CPPFLAGS=-I/usr/include/python3.10 \
./configure --prefix=/usr    \
            --disable-static \
            --with-default-dict=/usr/lib/cracklib/pw_dict &&
make

# Install to package directory
unset workdir
unset workdir1
workdir1=`pwd`
cd ..
workdir=`pwd`
cd $workdir1
make DESTDIR=$workdir/package install

install -v -m644 -D    ../cracklib-words-2.9.7.bz2 \
                         $workdir/package/usr/share/dict/cracklib-words.bz2    &&

bunzip2 -v               $workdir/package/usr/share/dict/cracklib-words.bz2    &&
ln -v -sf cracklib-words $workdir/package/usr/share/dict/words                 &&
install -v -m755 -d      $workdir/package/usr/lib/cracklib

# Build the debian package and rename it correctly.
cd ../
dpkg-deb --build package
mv package.deb cracklib_2.9.7_amd64.deb