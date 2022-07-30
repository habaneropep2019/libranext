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
tar xvfj gnupg-2.2.34.orig.tar.bz2

# Change directory to source
cd gnupg-2.2.34

# Configure and compile package
sed -e '/noinst_SCRIPTS = gpg-zip/c sbin_SCRIPTS += gpg-zip' \
    -i tools/Makefile.in
    
./configure --prefix=/usr            \
            --localstatedir=/var     \
            --sysconfdir=/etc        \
            --docdir=/usr/share/doc/gnupg-2.2.34 &&
make &&

makeinfo --html --no-split -o doc/gnupg_nochunks.html doc/gnupg.texi &&
makeinfo --plaintext       -o doc/gnupg.txt           doc/gnupg.texi &&
make -C doc html

# Install to package directory
unset workdir
unset workdir1
workdir1=`pwd`
cd ..
workdir=`pwd`
cd $workdir1
make DESTDIR=$workdir/package install

# Generate the documentation and put it into it's own folder to build
install -v -m755 -d $workdir/package-doc/usr/share/doc/gnupg-2.2.34/html            &&
install -v -m644    doc/gnupg_nochunks.html \
                    $workdir/package-doc/usr/share/doc/gnupg-2.2.34/html/gnupg.html &&
install -v -m644    doc/*.texi doc/gnupg.txt \
                    $workdir/package-doc/usr/share/doc/gnupg-2.2.34 &&
install -v -m644    doc/gnupg.html/* \
                    $workdir/package-doc/usr/share/doc/gnupg-2.2.34/html
                    
# Remove info file so we can manage it with maintainer scripts

cd $workdir/package/usr/share/info
rm dir
cd $workdir1

# Build the debian packages and rename them correctly.
cd ../
dpkg-deb --build package
dpkg-deb --build package-doc
mv package.deb gnupg_2.2.34_amd64.deb
mv package-doc.deb gnupg-doc_2.2.34_all.deb