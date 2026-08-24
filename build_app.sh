#!/bin/bash
set -e

echo "=== 1. Building Universal Release Binary (arm64 + x86_64) ==="
swift build -c release --triple arm64-apple-macosx
swift build -c release --triple x86_64-apple-macosx

APP_DIR="Nook Notes.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "=== 2. Assembling $APP_DIR Bundle ==="
rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

lipo -create .build/arm64-apple-macosx/release/NookNotes .build/x86_64-apple-macosx/release/NookNotes -output "$MACOS_DIR/NookNotes"

cp Resources/Info.plist "$CONTENTS_DIR/Info.plist"
if [ -f "Resources/AppIcon.icns" ]; then
    cp Resources/AppIcon.icns "$RESOURCES_DIR/AppIcon.icns"
fi
cp Resources/*.ttf "$RESOURCES_DIR/" 2>/dev/null || true

echo "=== 3. Code Signing App Bundle ==="
IDENTITY=$(security find-identity -v -p codesigning | grep "Apple Development" | head -n 1 | awk -F '"' '{print $2}')
if [ -n "$IDENTITY" ]; then
    echo "Signing with identity: $IDENTITY"
    codesign --force --deep --options runtime --sign "$IDENTITY" "$APP_DIR"
else
    echo "Signing with ad-hoc identity (-)"
    codesign --force --deep --sign - "$APP_DIR"
fi

echo "=== 4. Creating ZIP Distribution ==="
rm -f Nook-Notes.zip
zip -r -y Nook-Notes.zip "$APP_DIR" > /dev/null

echo "=== 5. Creating DMG Installer (Nook-Notes.dmg) ==="
rm -rf dmg_temp Nook-Notes.dmg
mkdir -p dmg_temp
cp -R "$APP_DIR" dmg_temp/
ln -s /Applications dmg_temp/Applications

hdiutil create -volname "Nook Notes" -srcfolder dmg_temp -ov -format UDZO Nook-Notes.dmg
rm -rf dmg_temp

echo "=== Packaging Complete! ==="
echo "App Bundle: $APP_DIR"
echo "DMG Installer: Nook-Notes.dmg"
echo "ZIP Archive: Nook-Notes.zip"
