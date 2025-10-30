#!/bin/bash

echo ""
echo "flutter analyze"
flutter analyze

# Build Flutter web
echo ""
echo "flutter build web --no-wasm-dry-run --output build-web/"
flutter build web --no-wasm-dry-run --output build-web/
exit_code=$?

if [ "$exit_code" -ne "0" ]; then
  echo ""
  echo "Flutter build web FAILED."
  echo ""
  exit 1
fi
