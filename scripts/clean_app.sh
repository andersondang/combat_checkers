#!/bin/bash

echo "=== Cleaning build directory"
/bin/rm -R build
mkdir build
echo ""

echo "=== flutter clean"
flutter clean
flutter pub get
echo ""

echo "=== clean ios"
cd ios
rm -rf build/ && rm -rf Pods/ && rm -rf .symlinks/ && rm -f Podfile.lock
pod repo update
pod install
cd ..
echo ""

#echo "=== clean macos"
#cd ios
#rm -rf Pods Podfile.lock
#pod repo update
#pod install
#cd ..
#echo ""

