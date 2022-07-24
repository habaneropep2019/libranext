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
tar xvf mpfr-4.1.0.orig.tar.xz

# Change directory to source
cd mpfr-4.1.0

# Configure and compile package
./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-4.1.0
make
make html

# Test suite doesn't run by default, but it is highly encouraged. Note that 4 tests are known to fail in a Libranext environment.
## This is generally not a concern as long as MPC passes its tests.

function testsuite {
	make check | less
	echo ""
	echo "4 tests are known to fail in a Libranext 4.0 environment"
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
cd ..
workdir=`pwd`
cd $workdir1
make DESTDIR=$workdir/package install
make DESTDIR=$workdir/package install-html

# Remove info file so we can manage it with maintainer scripts

cd $workdir/package/usr/share/info
rm dir
cd $workdir1

# Build the debian package and rename it correctly.
cd ../
dpkg-deb --build package
mv package.deb mpfr_4.1.0_amd64.deb