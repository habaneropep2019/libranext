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
tar xvf docbook-xsl-nons-1.79.2.orig.tar.bz2

# Change directory to source
cd docbook-xsl-nons-1.79.2

# Configure and compile package
patch -Np1 -i ../docbook-xsl-nons-1.79.2-stack_fix-1.patch

make

# Install to package directory
unset workdir
unset workdir1
workdir1=`pwd`
cd ..
workdir=`pwd`
cd $workdir1

tar -xvf ../docbook-xsl-doc-1.79.2.orig.tar.bz2 --strip-components=1

install -v -m755 -d $workdir/package/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2 &&

cp -v -R VERSION assembly common eclipse epub epub3 extensions fo        \
         highlighting html htmlhelp images javahelp lib manpages params  \
         profiling roundtrip slides template tests tools webhelp website \
         xhtml xhtml-1_1 xhtml5                                          \
    $workdir/package/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2 &&

ln -s VERSION $workdir/package/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2/VERSION.xsl &&

# Generate the documentation and put it into it's own folder to build
install -v -m644 -D README \
                    $workdir/package-doc/usr/share/doc/docbook-xsl-nons-1.79.2/README.txt &&
install -v -m644    RELEASE-NOTES* NEWS* \
                    $workdir/package-doc/usr/share/doc/docbook-xsl-nons-1.79.2

cp -v -R doc/* $workdir/package-doc/usr/share/doc/docbook-xsl-nons-1.79.2

# Build the debian packages and rename them correctly.
cd ../
dpkg-deb --build package
dpkg-deb --build package-doc
mv package.deb docbook-xsl_1.79.2_all.deb
mv package-doc.deb docbook-xsl-doc_1.79.2_all.deb