#!/bin/bash
rm -rf release.tar.bz2 release
mkdir release
cp .build/release/*.so release/
cp .build/release/WebComicTranslatePlatform release/
mkdir -p release/views
cp -r views/*.mustache release/views/

tar jcf release.tar.bz2 release

rm -rf release
