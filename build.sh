#!/bin/bash

set -e

DIR_SCRIPT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
FILE_SCRIPT="$(basename "$DIR_SCRIPT")"

exec 1> >(while IFS= read -r line; do echo "-- [$FILE_SCRIPT $(date +%H:%M:%S)] $line"; done)
exec 2> >(while IFS= read -r line; do echo "-- [$FILE_SCRIPT $(date +%H:%M:%S)] $line" >&2; done)

DIR_BUILD="$DIR_SCRIPT/build"
DIR_DIST="$DIR_SCRIPT/dist"

VERSION=1.8.5

# Check if is alpine
if ! [[ "$(cat /etc/*-release)" =~ alpine ]]; then
  echo "Please build on alpine linux"
fi

# Re-create dirs
if [ -d "$DIR_BUILD" ]; then
  echo "removing previous build directory"
  rm -rf "$DIR_BUILD"
fi

if [ -d "$DIR_DIST" ]; then
  echo "removing previous dist directory"
  rm -rf "$DIR_DIST"
fi

mkdir -p "$DIR_BUILD"
mkdir -p "$DIR_DIST"

cd "$DIR_BUILD"

# Fetch source
echo "downloading pv"
wget -O pv.tar.xz "http://www.ivarch.com/programs/sources/pv-$VERSION.tar.gz"
tar -xf pv.tar.xz --strip-components=1

# Configure GCC
echo "setting CC to musl-gcc and -static"
export CC=gcc
export CFLAGS="-static"

# Build
echo "building pv"
env FORCE_UNSAFE_CONFIGURE=1 CFLAGS="$CFLAGS -Os -ffunction-sections -fdata-sections" LDFLAGS='-Wl,--gc-sections' ./configure
make

cp "pv" "$DIR_DIST"

cd "$DIR_DIST"

echo "strip & compress"
strip -s -R .comment -R .gnu.version --strip-unneeded pv
upx --ultra-brute pv

echo "done"
