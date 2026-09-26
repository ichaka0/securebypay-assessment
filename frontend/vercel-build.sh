#!/bin/bash
set -e

FLUTTER_REPO="https://github.com/flutter/flutter.git"

if [ ! -d "flutter" ]; then
  git clone "$FLUTTER_REPO" --depth 1 -b stable flutter
fi

export PATH="$PATH:$(pwd)/flutter/bin"

flutter config --enable-web
flutter build web --release