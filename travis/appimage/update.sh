  
#!/bin/bash

$APPDIR/usr/bin/zenity --question --timeout=10 --title="dolphin updater" --text="New update available. Update now?" --icon-name=dolphin-emu --window-icon=dolphin-emu.svg --height=80 --width=400
answer=$?

if [ "$answer" -eq 0 ]; then 
	export LD_PRELOAD="$APPDIR/usr/lib/updater/libcurl.so.4"
	$APPDIR/usr/bin/AppImageUpdate $PWD/Dolphin_Emulator-x86_64.AppImage && $PWD/Dolphin_Emulator-x86_64.AppImage
elif [ "$answer" -eq 1 ]; then
	QT_QPA_PLATFORM=xcb $APPDIR/usr/bin/dolphin-emu
elif [ "$answer" -eq 5 ]; then
	QT_QPA_PLATFORM=xcb $APPDIR/usr/bin/dolphin-emu
fi
exit 0
