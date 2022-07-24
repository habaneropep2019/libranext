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
tar xvf binutils-2.38.orig.tar.xz

# Change directory to source
cd binutils-2.38

# Patch, configure and compile package
patch -Np1 -i ../binutils-2.38-lto_fix-1.patch
sed -e '/R_386_TLS_LE /i \   || (TYPE) == R_386_TLS_IE \\' \
    -i ./bfd/elfxx-x86.h
    
mkdir -v build
cd       build

../configure --prefix=/usr       \
             --enable-gold       \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --with-system-zlib
make tooldir=/usr

# binutils should have the testsuite run, at least one time per change in version or buildscript to ensure it's working correctly.
## By default, the testsuite does not run to allow automated builds. If buildling this manually, run the testsuite by passing
## -t as a command line option to this build script.

function testsuite {
	make -k check | less

	read -p 'Do you accept the test results? (yes/no):' testaccept

	if [ $testaccept == "no" ]
	then
		exit 1
	fi
}

while getopts "t" option; do
case ${option} in
t )
echo "Running test suite..."
testsuite
;;
\? )
echo "Not running test suite..."
sleep 2s
;;
esac
done

# Install to package directory
unset workdir
unset workdir1
workdir1=`pwd`
cd ../..
workdir=`pwd`
cd $workdir1
make DESTDIR=$workdir/package tooldir=/usr install

rm -fv $workdir/package/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.a

# Remove info file so we can manage it with maintainer scripts

cd $workdir/package/usr/share/info
rm dir
cd $workdir1

# Build the debian package and rename it correctly.
cd ../..
dpkg-deb --build package
mv package.deb binutils_2.38_amd64.deb