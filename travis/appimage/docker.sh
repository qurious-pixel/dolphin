#!/bin/bash -ex

branch=`echo ${GITHUB_REF##*/}`

QT_BASE_DIR=/opt/qt514
export QTDIR=$QT_BASE_DIR
export PATH=$QT_BASE_DIR/bin:$PATH
export LD_LIBRARY_PATH=$QT_BASE_DIR/lib/x86_64-linux-gnu:$QT_BASE_DIR/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$QT_BASE_DIR/lib/pkgconfig:$PKG_CONFIG_PATH

#ADD MISSING PACKAGES
apt update
apt install -y libgtk2.0-dev wx3.0-headers libmbedtls-dev gcc-9 g++-9
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 20 && \
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 20 && \
ln -s /usr/include/locale.h /usr/include/xlocale.h

ln -s /home/yuzu/.conan /root

cd /dolphin

export GIT_SSL_NO_VERIFY=1
git clone --recursive https://crediar.dev/crediar/dolphin.git
#git submodule update --init --recursive
cd dolphin/
#git submodule update --init Externals/mGBA
git reset --hard e3134bd93ddfa2d1a96e2aec5773d66badef2abe

git clone https://github.com/facebook/zstd.git --single-branch -b dev
cd zstd/build/cmake
mkdir builddir
cd builddir
cmake .. -GNinja -DCMAKE_INSTALL_PREFIX=/usr
ninja
ninja install
cd /dolphin/dolphin

#REPLACE CHAR_ with CHARACTER_ 
#https://forums.dolphin-emu.org/Thread-error-compiling-dolphin-s-netplay-build-5-0-321-under-pop-os-linux-ubuntu-17-10
#sed -i -e 's|CHAR_|CHARACTER_|g' Source/Core/VideoBackends/OGL/RasterFont.cpp

##TRIFORCE FIX
cp /dolphin/travis/common/CMakeLists_Core.txt Source/Core/Core/CMakeLists.txt
sed -i '/#include <winsock2.h>/i #ifdef _WIN32' Source/Core/Core/HW/DVD/AMBaseboard.cpp
sed -i '/#include <winsock2.h>/a #endif' Source/Core/Core/HW/DVD/AMBaseboard.cpp
sed -i 's/-Wshadow/-Wno-shadow/g' Source/CMakeLists.txt

mkdir build
cd build
cmake .. -G Ninja -DLINUX_LOCAL_DEV=true -DENABLE_CLI_TOOL=OFF -DENABLE_NOGUI=false -DENABLE_QT=ON -DENABLE_EVDEV=OFF -DCMAKE_C_COMPILER=/usr/lib/ccache/gcc -DCMAKE_CXX_COMPILER=/usr/lib/ccache/g++ # -DOpenGL_GL_PREFERENCE="LEGACY" -DOPENGL_opengl_LIBRARY=""
ninja
#ln -s ../../Data/Sys Binaries/

cd /tmp
curl -sLO "https://raw.githubusercontent.com/qurious-pixel/dolphin/$branch/travis/appimage/appimage.sh"
chmod a+x appimage.sh
./appimage.sh
#ls -al /dolphin
#ls -al /dolphin/build
#ls -al /dolphin/build/Binaries
