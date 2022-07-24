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
tar xvf gcc-11.2.0.orig.tar.xz

# Change directory to source
cd gcc-11.2.0

# Configure and compile package
sed -e '/static.*SIGSTKSZ/d' \
    -e 's/return kAltStackSize/return SIGSTKSZ * 4/' \
    -i libsanitizer/sanitizer_common/sanitizer_posix_libcdep.cpp

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
  ;;
esac

mkdir -v build
cd       build

../configure --prefix=/usr            \
             LD=ld                    \
             --enable-languages=c,c++ \
             --disable-multilib       \
             --disable-bootstrap      \
             --with-system-zlib
make

# GCC should have the testsuite run, at least one time per change in version or buildscript to ensure it's working correctly.
## By default, the testsuite does not run to allow automated builds. If buildling this manually, run the testsuite by passing
## -t as a command line option to this build script.

function testsuite {
	ulimit -s 32768

	echo "gcctester:x:101:101::/home/gcctester:/bin/bash" >> /etc/passwd
	echo "gcctester:x:101:" >> /etc/group
	install -o gcctester -d /home/gcctester

	chown -Rv gcctester .
	su gcctester -c "PATH=$PATH make -k check"
	userdel -r gcctester

	../contrib/test_summary | grep -A7 Summ. | less

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
make DESTDIR=$workdir/package install

rm -rf $workdir/package/usr/lib/gcc/$(gcc -dumpmachine)/11.2.0/include-fixed/bits/

chown -v -R root:root \
    $workdir/package/usr/lib/gcc/*linux-gnu/11.2.0/include{,-fixed}
    
mkdir -pv $workdir/package/usr/share/gdb/auto-load/usr/lib
mv -v $workdir/package/usr/lib/*gdb.py $workdir/package/usr/share/gdb/auto-load/usr/lib

# Remove info's dir file so we can manage it with maintainer scripts

cd $workdir/package/usr/share/info
rm dir
cd $workdir1

# Build the debian package and rename it correctly.
cd ../..
dpkg-deb --build package
mv package.deb gcc-minimal_11.2.0_amd64.deb