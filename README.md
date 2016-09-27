# orbit-ios

Puzzlebox Orbit for iOS

Copyright © 2016 Puzzlebox Productions, LLC. All rights reserved.

License: GNU Affero General Public License v3.0
https://www.gnu.org/licenses/agpl-3.0.html

Homepage: http://puzzlebox.io/orbit

============

Requirements:

- Xcode 8.0+ with support for Swift 3
- NeuroSky Stream SDK (for original MindWave Mobile EEG Headset support)
- NeuroSky MWM SDK (for MindWave Mobile Plus EEG Headset support)

============

Installation:

- Download iOS Developers Tools from NeuroSky (current version is 4.2)

 http://store.neurosky.com/products/ios-developer-tools-4

- Copy the following files from NeuroSky Stream SDK to Orbit source directory:

 Orbit/Libraries/StreamSDK/StreamSDK.a
 Orbit/Libraries/StreamSDK/TGSEEGPower.h
 Orbit/Libraries/StreamSDK/TGStream.h
 Orbit/Libraries/StreamSDK/TGStreamDelegate.h
 Orbit/Libraries/StreamSDK/TGStreamEnum.h

- Copy the following files from NeuroSky MWM SDK to Orbit source directory:

 Orbit/Libraries/MWMSDK/MWMDevice.h
 Orbit/Libraries/MWMSDK/MWMDeviceDelegate.h
 Orbit/Libraries/MWMSDK/TGBleManager.h
 Orbit/Libraries/MWMSDK/TGBleManagerDelegate.h
 Orbit/Libraries/MWMSDK/TGEnumInfo.h
 Orbit/Libraries/MWMSDK/libBleSDK.a

- Open project file Orbit.xcodeproj in Xcode 8.0+

- Compile and Run
