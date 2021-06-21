#!/bin/bash -ex

branch=`echo ${GITHUB_REF##*/}`

BUILDBIN=/dolphin/dolphin/build/Binaries
BINFILE=dolphin-emu-x86_64.AppImage
LOG_FILE=$HOME/curl.log
CXX=g++-9

# QT 5.14.2
# source /opt/qt514/bin/qt514-env.sh
QT_BASE_DIR=/opt/qt514
export QTDIR=$QT_BASE_DIR
export PATH=$QT_BASE_DIR/bin:$PATH
export LD_LIBRARY_PATH=$QT_BASE_DIR/lib/x86_64-linux-gnu:$QT_BASE_DIR/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$QT_BASE_DIR/lib/pkgconfig:$PKG_CONFIG_PATH

cd /tmp
	curl -sLO "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage"
	curl -sLO "https://github.com/AppImage/AppImageUpdate/releases/download/continuous/AppImageUpdate-x86_64.AppImage"
	chmod a+x AppImageUpdate-x86_64.AppImage
	chmod a+x linuxdeployqt*.AppImage
./linuxdeployqt-continuous-x86_64.AppImage --appimage-extract
cd $HOME
mkdir -p squashfs-root/usr/bin
cp -P "$BUILDBIN"/dolphin-emu $HOME/squashfs-root/usr/bin/

curl -sL https://raw.githubusercontent.com/qurious-pixel/dolphin/$branch/Data/dolphin-emu.svg -o ./squashfs-root/dolphin-emu.svg
curl -sL https://raw.githubusercontent.com/qurious-pixel/dolphin/$branch/Data/dolphin-emu.desktop -o ./squashfs-root/dolphin-emu.desktop
curl -sL https://github.com/AppImage/AppImageKit/releases/download/continuous/runtime-x86_64 -o ./squashfs-root/runtime
mkdir -p squashfs-root/usr/share/applications && cp ./squashfs-root/dolphin-emu.desktop ./squashfs-root/usr/share/applications
mkdir -p squashfs-root/usr/share/icons && cp ./squashfs-root/dolphin-emu.svg ./squashfs-root/usr/share/icons
mkdir -p squashfs-root/usr/share/icons/hicolor/scalable/apps && cp ./squashfs-root/dolphin-emu.svg ./squashfs-root/usr/share/icons/hicolor/scalable/apps
mkdir -p squashfs-root/usr/share/pixmaps && cp ./squashfs-root/dolphin-emu.svg ./squashfs-root/usr/share/pixmaps
mkdir -p squashfs-root/usr/optional/ ; mkdir -p squashfs-root/usr/optional/libstdc++/

mkdir -p squashfs-root/usr/share/dolphin-emu
cp -R /dolphin/dolphin/Data/Sys ./squashfs-root/usr/bin
curl -sL "https://raw.githubusercontent.com/qurious-pixel/dolphin/$branch/travis/appimage/update.sh" -o $HOME/squashfs-root/update.sh
curl -sL "https://raw.githubusercontent.com/qurious-pixel/dolphin/$branch/travis/appimage/AppRun" -o $HOME/squashfs-root/AppRun
curl -sL "https://github.com/RPCS3/AppImageKit-checkrt/releases/download/continuous2/AppRun-patched-x86_64" -o $HOME/squashfs-root/AppRun-patched
curl -sL "https://github.com/RPCS3/AppImageKit-checkrt/releases/download/continuous2/exec-x86_64.so" -o $HOME/squashfs-root/usr/optional/exec.so
chmod a+x ./squashfs-root/AppRun
chmod a+x ./squashfs-root/runtime
chmod a+x ./squashfs-root/AppRun-patched
chmod a+x ./squashfs-root/update.sh
#cp /tmp/libssl.so.47 /tmp/libcrypto.so.45 /usr/lib/x86_64-linux-gnu/
cp /usr/lib/x86_64-linux-gnu/libstdc++.so.6 squashfs-root/usr/optional/libstdc++/
printf "#include <bits/stdc++.h>\nint main(){std::make_exception_ptr(0);std::pmr::get_default_resource();}" | $CXX -x c++ -std=c++2a -o $HOME/squashfs-root/usr/optional/checker -

echo $GITHUB_RUN_ID > $HOME/squashfs-root/version.txt

unset QT_PLUGIN_PATH
unset LD_LIBRARY_PATH
unset QTDIR

# /tmp/squashfs-root/AppRun $HOME/squashfs-root/usr/bin/dolphin-emu -appimage -unsupported-allow-new-glibc -no-copy-copyright-files -no-translations -bundle-non-qt-libs
/tmp/squashfs-root/AppRun $HOME/squashfs-root/usr/bin/dolphin-emu -unsupported-allow-new-glibc -no-copy-copyright-files -no-translations -bundle-non-qt-libs
export PATH=$(readlink -f /tmp/squashfs-root/usr/bin/):$PATH

# Add AppImageUpdate as the internal updater
mv /tmp/AppImageUpdate-x86_64.AppImage $HOME/squashfs-root/usr/bin/AppImageUpdate

# Add dialog as the fallback
cp /usr/bin/dialog ./squashfs-root/usr/bin/
cp /lib/x86_64-linux-gnu/libncursesw.so.5 $HOME/squashfs-root/usr/lib/
cp /lib/x86_64-linux-gnu/libtinfo.so.5 $HOME/squashfs-root/usr/lib/

# Copy libOpenGL deps
cp /usr/lib/x86_64-linux-gnu/libGLdispatch.so.0 $HOME/squashfs-root/usr/lib/

# Package AppImage
/tmp/squashfs-root/usr/bin/appimagetool $HOME/squashfs-root -u "gh-releases-zsync|qurious-pixel|dolphin|continuous|Dolphin_Emulator-x86_64.AppImage.zsync"

mkdir $HOME/artifacts/
mkdir -p /dolphin/artifacts/
mv Dolphin_Emulator-x86_64.AppImage* $HOME/artifacts
cp -R $HOME/artifacts/ /dolphin/
cp $BUILDBIN/{dolphin-emu,dolphin-emu-nogui} /dolphin/artifacts
chmod -R 777 /dolphin/artifacts
cd /dolphin/artifacts
ls -al /dolphin/artifacts/
#curl --upload-file Dolphin_Emulator-x86_64.AppImage https://transfersh.com/Dolphin_Emulator-x86_64.AppImage
