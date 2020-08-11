#!/bin/bash -ex

QT_BASE_DIR=/opt/qt514
export QTDIR=$QT_BASE_DIR
export PATH=$QT_BASE_DIR/bin:$PATH
export LD_LIBRARY_PATH=$QT_BASE_DIR/lib/x86_64-linux-gnu:$QT_BASE_DIR/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$QT_BASE_DIR/lib/pkgconfig:$PKG_CONFIG_PATH

apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y cmake libudev-dev libsfml-dev libminiupnpc-dev libmbedtls-dev libcurl4-openssl-dev libhidapi-dev libsystemd-dev libbluetooth-dev libpulse-dev libpugixml-dev libbz2-dev liblzo2-dev libpng-dev libusb-1.0-0-dev gettext \
qtbase5-private-dev
#curl -sLO "http://launchpadlibrarian.net/325446110/libusb-1.0-0-dev_1.0.21-2_amd64.deb"
#curl -sLO "http://mirrors.kernel.org/ubuntu/pool/main/libu/libusb-1.0/libusb-1.0-0-dev_1.0.20-1_amd64.deb"
#dpkg -i *.deb

cd /dolphin

mkdir build
cd build
cmake .. -G Ninja -DLINUX_LOCAL_DEV=true -DCMAKE_C_COMPILER=/usr/bin/gcc -DCMAKE_CXX_COMPILER=/usr/bin/g++
ninja
ln -s ../../Data/Sys Binaries/

cat /dolphin/build/CMakeFiles/CMakeError.log | curl -F 'f:1=<-' ix.io

cd /tmp
#curl -sLO "https://raw.githubusercontent.com/qurious-pixel/dolphin/zap/travis/appimage/appimage.sh"
#chmod a+x appimage.sh
#./appimage.sh
ls -al /dolphin
ls -al /dolphin/build
ls -al /dolphin/build/bin
