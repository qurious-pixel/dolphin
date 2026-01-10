set(STORYBOARDS Main.storyboard)

set(SOURCES
  main.m
  AppDelegate.h
  AppDelegate.mm
  ViewController.h
  ViewController.m
  MacUI.mm
  ${STORYBOARDS}
)

add_executable(MacUpdater ${SOURCES})

add_dependencies(MacUpdater dolphin_scmrev)

set_target_properties(MacUpdater PROPERTIES
  MACOSX_BUNDLE true
  MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/Info.plist.in"
  OUTPUT_NAME "Dolphin Updater")

# Copy icon into the bundle
target_sources(MacUpdater PRIVATE "${CMAKE_SOURCE_DIR}/Data/Dolphin.icns")
set_source_files_properties("${CMAKE_SOURCE_DIR}/Data/Dolphin.icns" PROPERTIES MACOSX_PACKAGE_LOCATION Resources)

target_link_libraries(MacUpdater PRIVATE
    "-framework Cocoa"
    "-framework AppKit"
    "-framework CoreData"
    "-framework Foundation"
    uicommon
    updatercommon
)

set_source_files_properties(${STORYBOARDS} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)

include(DolphinInjectVersionInfo)
dolphin_inject_version_info(MacUpdater)

if(NOT SKIP_POSTPROCESS_BUNDLE)
  # Update library references to make the bundle portable
  include(DolphinPostprocessBundle)
  dolphin_postprocess_bundle(MacUpdater)

  # Fix rpath
  add_custom_command(TARGET MacUpdater
    POST_BUILD COMMAND
    ${CMAKE_INSTALL_NAME_TOOL} -add_rpath "@executable_path/../Frameworks/"
    $<TARGET_FILE:MacUpdater>)
endif()

if(MACOS_CODE_SIGNING)
  add_custom_command(TARGET MacUpdater
    POST_BUILD
    COMMAND "${CMAKE_SOURCE_DIR}/Tools/mac-codesign.sh"
    "${MACOS_CODE_SIGNING_IDENTITY}"
    "$<TARGET_BUNDLE_DIR:MacUpdater>"
  )
endif()
