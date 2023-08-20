#!/bin/sh
brew install create-dmg
test -f aimigo.dmg && rm aimigo.dmg
create-dmg \
  --volname "Flutter Template" \
  --volicon "./AppIcon.icns" \
  --window-pos 200 120 \
  --window-size 800 500 \
  --icon-size 100 \
  --icon "aimigo.app" 200 190 \
  --hide-extension "aimigo.app" \
  --app-drop-link 600 185 \
  "aimigo.dmg" \
  "../build/macos/Build/Products/Release/aimigo.app"

