#!/bin/bash
set -e

FLUTTER_REPO="https://github.com/flutter/flutter.git"

if [ ! -d "flutter" ]; then
  git clone "$FLUTTER_REPO" --depth 1 -b stable flutter
fi

export PATH="$PATH:$(pwd)/flutter/bin"

flutter config --enable-web

# Release builds call the Render API by default
# (https://securebypay-assessment-wf1p.onrender.com/api, see
# lib/core/config/app_config.dart). Set API_BASE_URL in the Vercel project's
# Environment Variables only to point at a different backend (the /api suffix
# is added automatically if omitted).
if [ -n "$API_BASE_URL" ]; then
  flutter build web --release --dart-define=API_BASE_URL="$API_BASE_URL"
else
  flutter build web --release
fi
