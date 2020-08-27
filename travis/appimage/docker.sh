#!/bin/bash -ex

branch=$TRAVIS_BRANCH

QT_BASE_DIR=/opt/qt514
export QTDIR=$QT_BASE_DIR
export PATH=$QT_BASE_DIR/bin:$PATH
export LD_LIBRARY_PATH=$QT_BASE_DIR/lib/x86_64-linux-gnu:$QT_BASE_DIR/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$QT_BASE_DIR/lib/pkgconfig:$PKG_CONFIG_PATH

ln -s /home/yuzu/.conan /root

CMAKEVER=3.18.1

	cd /tmp 
	curl -sLO https://cmake.org/files/v${CMAKEVER%.*}/cmake-${CMAKEVER}-Linux-x86_64.sh 
	sh cmake-${CMAKEVER}-Linux-x86_64.sh --prefix=/usr --skip-license 
	rm ./cmake*.sh 
	cmake --version

cd /dolphin

git clone https://github.com/dolphin-emu/dolphin.git
git submodule update --init --recursive
cd dolphin/

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
