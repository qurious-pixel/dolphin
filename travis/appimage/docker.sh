#!/bin/bash -ex

apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y ca-certificates qtbase5-dev qtbase5-private-dev git cmake make gcc g++ pkg-config libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libxi-dev libxrandr-dev libudev-dev libevdev-dev libsfml-dev libminiupnpc-dev libmbedtls-dev libcurl4-openssl-dev libhidapi-dev libsystemd-dev libbluetooth-dev libasound2-dev libpulse-dev libpugixml-dev libbz2-dev libzstd-dev liblzo2-dev libpng-dev libusb-1.0-0-dev gettext
#curl -sLO "http://launchpadlibrarian.net/325446110/libusb-1.0-0-dev_1.0.21-2_amd64.deb"
#curl -sLO "http://mirrors.kernel.org/ubuntu/pool/main/libu/libusb-1.0/libusb-1.0-0-dev_1.0.20-1_amd64.deb"
#dpkg -i *.deb

cd /dolphin

mkdir build
cd build
cmake .. -G Ninja -DLINUX_LOCAL_DEV=true
ninja
ln -s ../../Data/Sys Binaries/

cd /tmp
curl -sLO "https://raw.githubusercontent.com/qurious-pixel/dolphin/zap/travis/appimage/appimage.sh"
chmod a+x appimage.sh
./appimage.sh
