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

# Change directory to source
cd nss-3.75

# Configure and compile package
patch -Np1 -i ../nss-3.75-standalone-1.patch &&

cd nss &&

make BUILD_OPT=1                  \
  NSPR_INCLUDE_DIR=/usr/include/nspr  \
  USE_SYSTEM_ZLIB=1                   \
  ZLIB_LIBS=-lz                       \
  NSS_ENABLE_WERROR=0                 \
  $([ $(uname -m) = x86_64 ] && echo USE_64=1) \
  $([ -f /usr/include/sqlite3.h ] && echo NSS_USE_SYSTEM_SQLITE=1)

# Install to package directory
cd ../dist                                                          &&

install -v -m755 Linux*/lib/*.so              ../../package/usr/lib              &&
install -v -m644 Linux*/lib/{*.chk,libcrmf.a} ../../package/usr/lib              &&

install -v -m755 -d                           ../../package/usr/include/nss      &&
cp -v -RL {public,private}/nss/*              ../../package/usr/include/nss      &&
chmod -v 644                                  ../../package/usr/include/nss/*    &&

install -v -m755 Linux*/bin/{certutil,nss-config,pk12util} ../../package/usr/bin &&

install -v -m644 Linux*/lib/pkgconfig/nss.pc  ../../package/usr/lib/pkgconfig

# Build the debian package and rename it correctly.
cd ../..
dpkg-deb --build package
mv package.deb nss_3.75_amd64.deb