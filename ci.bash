#! /bin/bash
set -e errexit
set -o pipefail

PROJ="EonilSeries"
xcodebuild -scheme "$PROJ"-macOS -configuration Debug clean build test
xcodebuild -scheme "$PROJ"-macOS -configuration Release clean build

#IOS_DEST="platform=iOS Simulator,name=iPhone 6,OS=latest"
IOS_DEST=id=`instruments -s devices | grep "iPhone" | grep "Simulator" | tail -1 | grep -o "\[.*\]" | tr -d "[]"`
#xcodebuild -scheme "$PROJ"-iOS -destination "$IOS_DEST" -configuration Debug clean build test
xcodebuild -scheme "$PROJ"-iOS -destination "$IOS_DEST" -configuration Release clean build

