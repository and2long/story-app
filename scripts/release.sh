#!/bin/bash

# Extract version name and build number from pubspec.yaml
version_name=$(grep "version: " pubspec.yaml | sed 's/version: //' | cut -d '+' -f 1)
build_number=$(grep "version: " pubspec.yaml | sed 's/version: //' | cut -d '+' -f 2)

echo "Version name: $version_name"
echo "Build number: $build_number"

# Build APK
flutter build apk --build-name=$version_name --build-number=$build_number

# Rename APK
mv build/app/outputs/flutter-apk/app-release.apk story-v$version_name+$build_number-universal-release.apk