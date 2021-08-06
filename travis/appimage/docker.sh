#!/bin/bash -ex

branch=`echo ${GITHUB_REF##*/}`

QT_BASE_DIR=/opt/qt514
export QTDIR=$QT_BASE_DIR
export PATH=$QT_BASE_DIR/bin:$PATH
export LD_LIBRARY_PATH=$QT_BASE_DIR/lib/x86_64-linux-gnu:$QT_BASE_DIR/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$QT_BASE_DIR/lib/pkgconfig:$PKG_CONFIG_PATH

#ADD MISSING PACKAGES
sudo apt update
sudo apt install -y libgtk2.0-dev


ln -s /home/yuzu/.conan /root

cd /dolphin

git clone https://github.com/dolphin-emu/dolphin.git
git submodule update --init --recursive
cd dolphin/
git reset --hard be9416c462b1b5f0074d8a3a2b35171f2a154693

mkdir build
cd build
cmake .. -G Ninja -DLINUX_LOCAL_DEV=true -DENABLE_NOGUI=true -DENABLE_QT=OFF -DENABLE_EVDEV=OFF -DCMAKE_C_COMPILER=/usr/lib/ccache/gcc -DCMAKE_CXX_COMPILER=/usr/lib/ccache/g++
ninja
#ln -s ../../Data/Sys Binaries/

cd /tmp
curl -sLO "https://raw.githubusercontent.com/qurious-pixel/dolphin/$branch/travis/appimage/appimage.sh"
chmod a+x appimage.sh
./appimage.sh
#ls -al /dolphin
#ls -al /dolphin/build
#ls -al /dolphin/build/Binaries
