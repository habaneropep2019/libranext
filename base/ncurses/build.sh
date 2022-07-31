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
tar xvf ncurses-6.3.orig.tar.gz

# Change directory to source
cd ncurses-6.3

# Configure and compile package
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --enable-pc-files       \
            --enable-widec          \
            --with-pkg-config-libdir=/usr/lib/pkgconfig
make

# Install to package directory
unset workdir
unset workdir1
workdir1=`pwd`
cd ..
workdir=`pwd`
cd $workdir1
make DESTDIR=$workdir/package/dest install
install -vm755 $workdir/package/dest/usr/lib/libncursesw.so.6.3 $workdir/package/dest/usr/lib
rm -v  $workdir/package/dest/usr/lib/{libncursesw.so.6.3,libncurses++w.a}
cp -av $workdir/package/dest/* $workdir/package/

for lib in ncurses form panel menu ; do
    rm -vf                    $workdir/package/usr/lib/lib${lib}.so
    echo "INPUT(-l${lib}w)" > $workdir/package/usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc        $workdir/package/usr/lib/pkgconfig/${lib}.pc
done

rm -vf                     $workdir/package/usr/lib/libcursesw.so
echo "INPUT(-lncursesw)" > $workdir/package/usr/lib/libcursesw.so
ln -sfv libncurses.so      $workdir/package/usr/lib/libcurses.so

# Build the documentation
mkdir -pv      $workdir/package-doc/usr/share/doc/ncurses-6.3
cp -v -R doc/* $workdir/package-doc/usr/share/doc/ncurses-6.3

# Cleanup a little
rm -rv $workdir/package/dest

# Build the debian package and rename it correctly.
cd ../
dpkg-deb --build package
dpkg-deb --build package-doc
mv package.deb ncurses_6.3_amd64.deb
mv package-doc.deb ncurses-doc_6.3_all.deb