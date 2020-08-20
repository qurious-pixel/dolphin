#!/bin/bash -ex

branch=$TRAVIS_BRANCH

GCCVER=9
GCC_BINARY=gcc-${GCCVER}
GXX_BINARY=g++-${GCCVER}
QT_BASE_DIR=/opt/qt514
export QTDIR=$QT_BASE_DIR
export PATH=$QT_BASE_DIR/bin:$PATH
export LD_LIBRARY_PATH=$QT_BASE_DIR/lib/x86_64-linux-gnu:$QT_BASE_DIR/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$QT_BASE_DIR/lib/pkgconfig:$PKG_CONFIG_PATH

ln -s /home/yuzu/.conan /root

apt-get update -y
#DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y libudev-dev libsfml-dev libminiupnpc-dev libmbedtls-dev libcurl4-openssl-dev libhidapi-dev libsystemd-dev libbluetooth-dev libpulse-dev libpugixml-dev libbz2-dev liblzo2-dev libpng-dev libusb-1.0-0-dev gettext \
#qtbase5-private-dev libzstd-dev
DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y $GCC_BINARY $GXX_BINARY libsfml-dev libminiupnpc-dev libmbedtls-dev libcurl4-openssl-dev libhidapi-dev libsystemd-dev libbluetooth-dev libpugixml-dev libbz2-dev liblzo2-dev libpng-dev gettext

	update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${GCCVER} 20 
	update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-${GCCVER} 20 
  gcc --version 
	g++ --version 
	
cd /dolphin

mkdir build
cd build
cmake .. -G Ninja -DLINUX_LOCAL_DEV=true -DCMAKE_C_COMPILER=/usr/lib/ccache/gcc -DCMAKE_CXX_COMPILER=/usr/lib/ccache/g++
ninja
#ln -s ../../Data/Sys Binaries/

cat /dolphin/build/CMakeFiles/CMakeError.log | curl -F 'f:1=<-' ix.io

cd /tmp
curl -sLO "https://raw.githubusercontent.com/qurious-pixel/dolphin/$branch/travis/appimage/appimage.sh"
chmod a+x appimage.sh
./appimage.sh
#ls -al /dolphin
#ls -al /dolphin/build
#ls -al /dolphin/build/Binaries
