#!/bin/bash
# Face It for Mac: builds and installs the app without Xcode.
set -e
if ! xcrun --find swiftc >/dev/null 2>&1; then
  echo ""
  echo "Apple's free command line tools are needed (one time)."
  echo "Click Install in the window that opens. When it is done, run the same command again."
  xcode-select --install || true
  exit 0
fi
echo "Building Face It..."
TMP=$(mktemp -d)
curl -fsSL "https://raw.githubusercontent.com/eminahmadzada/face-it/8ce89b5/mac-app/FaceItApp.swift?$(date +%s)" -o "$TMP/FaceItApp.swift"
APP="$HOME/Applications/FaceIt.app"
pkill -x FaceIt 2>/dev/null || true
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
for f in BebasNeue-Regular.ttf Montserrat-SemiBold.ttf OFL.txt; do
  curl -fsSL "https://raw.githubusercontent.com/eminahmadzada/face-it/8ce89b5/mac-app/fonts/$f" -o "$APP/Contents/Resources/$f"
done
xcrun swiftc -O -parse-as-library -target "$(uname -m)-apple-macos13" "$TMP/FaceItApp.swift" -o "$APP/Contents/MacOS/FaceIt"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>com.emin.faceit</string>
<key>CFBundleName</key><string>FaceIt</string>
<key>CFBundleExecutable</key><string>FaceIt</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>1.0</string>
<key>LSMinimumSystemVersion</key><string>13.0</string>
<key>LSUIElement</key><true/>
</dict></plist>
PLIST
codesign --force -s - "$APP" >/dev/null 2>&1 || true
open "$APP"
osascript -e "tell application \"System Events\" to if not (exists login item \"FaceIt\") then make login item at end with properties {path:\"$APP\", hidden:false}" >/dev/null 2>&1 || true
echo ""
echo "Done. Face It is on your desktop (top right). Drag to move, drag edges to resize, click for next. Menu bar icon F for font and quit."
