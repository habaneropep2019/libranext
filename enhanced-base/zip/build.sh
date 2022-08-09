#!/bin/bash

# Debian packaging code Copyright © 2022 Alec Bloss
#
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

function build-30 {
	pushd releases/30/
	bash build.sh
	popd
	cp releases/3.0/*.deb .
}

function build-30-deb12 {
	pushd releases/3.0-deb12/
	bash build.sh
	popd
	cp releases/3.0-deb12/*.deb .
}

function latest {
	build-30-deb12
}


if [ -z "$1" ]
then
	echo "Defaulting to latest version..."
	latest
else
	case "$1" in
		3.0-deb12)
			build-30-deb12
			;;
		3.0)
			build-30
			;;
		*)
			echo 'Fatal: Invalid option'
			echo 'Available versions:'
			echo '- 3.0-deb12 (default)'
			echo '- 3.0'
			exit 1
			;;
		esac
fi