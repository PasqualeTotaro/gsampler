#!/bin/bash

# MACOS BUILD SCRIPT
version=1.0.0
buildStandalone=1
buildPlugin=1
buildInstaller=1
codesignStandalone=1
codesignPlugin=1
notarize=1

hiseSource="/Volumes/Shared/HISE"
projectName="Demo"
projectFolder="/Users/john/Desktop/demo"
xmlFile="demo"
teamId="TEAM NAME (1A273BC4DE)"
appleId="name@email.com"
appSpecificPassword="lawe-fygh-xhrc-wwyo"

bundleId='com.'${projectName// /}'.pkg'
hisePath=$hiseSource"/projects/standalone/Builds/MacOSX/build/Release/HISE.app/Contents/MacOS/HISE"
projuectPath=$hiseSource"/tools/projucer/Projucer.app/Contents/MacOS/Projucer"
whiteboxPackages="/usr/local/bin/packagesbuild"

#Create packaging directory for packaging
packaging="$projectFolder/Packaging/OSX"
mkdir -p "$packaging"

mkdir -p "$projectFolder/Binaries"
cd "$projectFolder/Binaries" || exit

# STEP 1: BUILDING THE BINARIES
# ====================================================================
"$hisePath" set_project_folder -p:$projectFolder
"$hisePath" set_version -v:$version

echo Making the Projucer accessible for this project
chmod +x "$projuectPath"

if (($buildStandalone==1))
then
  echo Building the standalone app
  "$hisePath" clean -p:$projectFolder --all
  "$hisePath" export_ci XmlPresetBackups/$xmlFile.xml -t:standalone -a:x64
  chmod +x ./batchCompileOSX
  sh ./batchCompileOSX
  cp -R "./Compiled/$projectName.app" "$packaging/$projectName.app"
fi

if (($buildPlugin==1))
then
  echo Building the plugins
  "$hisePath" clean -p:$projectFolder --all
  "$hisePath" export_ci XmlPresetBackups/$xmlFile.xml -t:instrument -p:VST_AU -a:x64
  chmod +x "./batchCompileOSX"
  sh "./batchCompileOSX"
  cp -R "./Builds/MacOSX/build/Release/$projectName.vst3" "$packaging/$projectName.vst3"
  cp -R "./Builds/MacOSX/build/Release/$projectName.component" "$packaging/$projectName.component"
fi

echo Codesigning

if [[ $codesignStandalone = 1 ]]
then
  codesign --remove-signature "$packaging/$projectName.app"
  codesign --deep --force --options runtime --sign "Developer ID Application: $teamId" "$packaging/$projectName.app"
fi

if [[ $codesignPlugin = 1 ]]
then
  codesign --remove-signature "$packaging/$projectName.vst3"
  codesign --remove-signature "$packaging/$projectName.component"
  codesign -s "Developer ID Application: $teamId" "$packaging/$projectName.vst3" --timestamp
  codesign -s "Developer ID Application: $teamId" "$packaging/$projectName.component" --timestamp
fi

# STEP 2: BUILDING INSTALLER
# ====================================================================

if (($buildInstaller==1))
then
  echo "Build Installer"

  $whiteboxPackages "$packaging/$projectName.pkgproj"

  productsign --sign "Developer ID Installer: $teamId" "$packaging/build/$projectName.pkg" "$packaging/build/$projectName""_signed.pkg"

  cp -R "$packaging/build/$projectName""_signed.pkg" "$packaging/$projectName Installer $version.pkg"

  echo "Cleanup"
  rm -rf "$packaging/build"

if (($notarize==1))
then

  echo "Notarizing"

  # create temporary files
  NOTARIZE_APP_LOG=$(mktemp -t notarize-app)
  NOTARIZE_INFO_LOG=$(mktemp -t notarize-info)

  # delete temporary files on exit
  function finish {
    rm "$NOTARIZE_APP_LOG" "$NOTARIZE_INFO_LOG"
  }
  trap finish EXIT

  if xcrun altool --notarize-app --primary-bundle-id "$bundleId" --username "$appleId" --password "$appSpecificPassword" -f "$packaging/$projectName Installer $version.pkg" > "$NOTARIZE_APP_LOG" 2>&1; then
    cat "$NOTARIZE_APP_LOG"
    RequestUUID=$(awk -F ' = ' '/RequestUUID/ {print $2}' "$NOTARIZE_APP_LOG")

    # check status periodically
    while sleep 60 && date; do
      # check notarization status
      if xcrun altool --notarization-info "$RequestUUID" --username "$appleId" --password "$appSpecificPassword" > "$NOTARIZE_INFO_LOG" 2>&1; then
        cat "$NOTARIZE_INFO_LOG"

        # once notarization is complete, run stapler and exit
        if ! grep -q "Status: in progress" "$NOTARIZE_INFO_LOG"; then
          xcrun stapler staple "$packaging/$projectName Installer $version.pkg"
          exit $?
        fi
      else
        cat "$NOTARIZE_INFO_LOG" 1>&2
        exit 1
      fi
    done
  else
    cat "$NOTARIZE_APP_LOG" 1>&2
    exit 1
  fi
fi

else
  echo "Skip Building Installer"
fi
