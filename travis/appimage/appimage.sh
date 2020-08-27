#!/bin/bash -ex

branch=$TRAVIS_BRANCH

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
	curl -sLO "https://github.com/qurious-pixel/dolphin/raw/$branch/travis/appimage/update.tar.gz"
	tar -xzf update.tar.gz
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
mkdir -p squashfs-root/usr/share/zenity 
cp /usr/share/zenity/zenity.ui ./squashfs-root/usr/share/zenity
cp /usr/bin/zenity ./squashfs-root/usr/bin/
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


echo $TRAVIS_COMMIT > $HOME/squashfs-root/version.txt

unset QT_PLUGIN_PATH
unset LD_LIBRARY_PATH
unset QTDIR

# /tmp/squashfs-root/AppRun $HOME/squashfs-root/usr/bin/dolphin-emu -appimage -unsupported-allow-new-glibc -no-copy-copyright-files -no-translations -bundle-non-qt-libs
/tmp/squashfs-root/AppRun $HOME/squashfs-root/usr/bin/dolphin-emu -unsupported-allow-new-glibc -no-copy-copyright-files -no-translations -bundle-non-qt-libs
export PATH=$(readlink -f /tmp/squashfs-root/usr/bin/):$PATH
cp /usr/lib/x86_64-linux-gnu/libp11-kit.so.0 $HOME/squashfs-root/usr/lib/
cp /usr/lib/x86_64-linux-gnu/libselinux.so* $HOME/squashfs-root/usr/lib/
mv /tmp/update/AppImageUpdate $HOME/squashfs-root/usr/bin/
mv /tmp/update/* $HOME/squashfs-root/usr/lib/
rm $HOME/squashfs-root/usr/lib/libOpenGL.so.0
/tmp/squashfs-root/usr/bin/appimagetool $HOME/squashfs-root -u "gh-releases-zsync|qurious-pixel|dolphin|continuous|Dolphin_Emulator-x86_64.AppImage.zsync"

mkdir $HOME/artifacts/
mkdir -p /dolphin/artifacts/
mv Dolphin_Emulator-x86_64.AppImage* $HOME/artifacts
cp -R $HOME/artifacts/ /dolphin/
chmod -R 777 /dolphin/artifacts
cd /dolphin/artifacts
ls -al /dolphin/artifacts/
curl --upload-file Dolphin_Emulator-x86_64.AppImage https://transfersh.com/Dolphin_Emulator-x86_64.AppImage

# touch $HOME/curl.log
# curl --progress-bar --upload-file $BINFILE https://transfer.sh/$BINFILE | tee -a "$LOG_FILE" ; test ${PIPESTATUS[0]} -eq 0
# echo "" >> $LOG_FILE
# cat $LOG_FILE
