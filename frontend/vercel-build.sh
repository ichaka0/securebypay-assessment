#!/bin/bash
set -e

FLUTTER_REPO="https://github.com/flutter/flutter.git"

if [ ! -d "flutter" ]; then
  git clone "$FLUTTER_REPO" --depth 1 -b stable flutter
fi

export PATH="$PATH:$(pwd)/flutter/bin"

# URL of the deployed NestJS API, including the /api prefix.
# Set API_BASE_URL in the Vercel project's Environment Variables.
if [ -z "$API_BASE_URL" ]; then
  echo "Error: API_BASE_URL is not set (e.g. https://<your-api-host>/api)." >&2
  exit 1
fi

flutter config --enable-web
flutter build web --release --dart-define=API_BASE_URL="$API_BASE_URL"
