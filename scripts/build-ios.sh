#!/bin/bash

echo ""
echo "flutter analyze"
flutter analyze
exit_code=$?

if [ "$exit_code" -ne "0" ]; then
  echo ""
  echo "Flutter analyze FAILED.."
  echo ""
  exit 1
fi


# Build Flutter ios
echo ""
echo "flutter build ios --config-only --release"
flutter build ios --config-only --release
exit_code=$?

if [ "$exit_code" -ne "0" ]; then
  echo ""
  echo "Flutter build ios FAILED."
  echo ""
  exit 1
fi

