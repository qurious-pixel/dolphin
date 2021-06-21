#!/bin/bash -ex

branch=`echo ${GITHUB_REF##*/}`

QT_BASE_DIR=/opt/qt514
export QTDIR=$QT_BASE_DIR
export PATH=$QT_BASE_DIR/bin:$PATH
export LD_LIBRARY_PATH=$QT_BASE_DIR/lib/x86_64-linux-gnu:$QT_BASE_DIR/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$QT_BASE_DIR/lib/pkgconfig:$PKG_CONFIG_PATH

ln -s /home/yuzu/.conan /root

cd /dolphin

git clone https://github.com/dolphin-emu/dolphin.git
git submodule update --init --recursive
cd dolphin/

mkdir build
cd build
cmake .. -G Ninja -DLINUX_LOCAL_DEV=true -DENABLE_NOGUI=true -DCMAKE_C_COMPILER=/usr/lib/ccache/gcc -DCMAKE_CXX_COMPILER=/usr/lib/ccache/g++
ninja
#ln -s ../../Data/Sys Binaries/

#Test Headless 
cd Binaries
ls -al .
curl -sLO "https://github.com/emukidid/swiss-gc/releases/download/v0.5r1086/swiss_r1086.tar.xz"
tar -xvf swiss_r1086.tar.xz
mv 'swiss_r1086/ISO/swiss_r1086(ntsc-u).iso' .
timeout 10s ./dolphin-emu-nogui --platform=headless -e 'swiss_r1086(ntsc-u).iso' 


cd /tmp
curl -sLO "https://raw.githubusercontent.com/qurious-pixel/dolphin/$branch/travis/appimage/appimage.sh"
chmod a+x appimage.sh
./appimage.sh
#ls -al /dolphin
#ls -al /dolphin/build
#ls -al /dolphin/build/Binaries
