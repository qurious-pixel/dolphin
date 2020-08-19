#!/bin/bash

$APPDIR/usr/bin/zenity --question --timeout=10 --title="dolphin updater" --text="New update available. Update now?" --icon-name=dolphin-emu --window-icon=dolphin-emu.svg --height=80 --width=400
answer=$?

if [ "$answer" -eq 0 ]; then 
	$APPDIR/usr/bin/AppImageUpdate $PWD/Dolphin_Emulator-x86_64.AppImage && $PWD/Dolphin_Emulator-x86_64.AppImage
elif [ "$answer" -eq 1 ]; then
	$APPDIR/AppRun-patched
elif [ "$answer" -eq 5 ]; then
	$APPDIR/AppRun-patched
fi
exit 0
