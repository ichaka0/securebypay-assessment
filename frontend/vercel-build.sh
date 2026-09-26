#!/bin/bash
# 1. Clone Flutter into a local directory if it doesn't exist
if [ ! -d "flutter" ]; then
  git clone https://github.com --depth 1 -b stable flutter
fi

# 2. Add Flutter to the executable path
export PATH="\$PATH:`pwd`/flutter/bin"

# 3. Configure and build the web app
flutter config --enable-web
flutter build web --release