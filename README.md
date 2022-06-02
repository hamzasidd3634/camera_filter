# Camera Filters

Realtime Camera Filters


# Description

This package will use camera with dynamic color list of filters, crop your image, text on image , change the text color and you can also use emojis. You can use your own custom color list to change filters. In the end it will provide you an edited image in onDone listener

# Features

* Realtime Camera Filters.
* Draw, add text change filters in camera.
* Filters on video.
* TextOverlay on video.

# IOS

The camera_filters plugin compiles for any version of iOS, but its functionality requires iOS 10 or higher. If compiling for iOS 9, make sure to programmatically check the version of iOS running on the device before using any camera_filters plugin features.

Add two rows to the ios/Runner/Info.plist:

* one with the key Privacy - Camera Usage Description and a usage description.
* and one with the key Privacy - Microphone Usage Description and a usage description.
  If editing Info.plist as text, add:
```yaml
    <key>NSCameraUsageDescription</key>
    <string>your usage description here</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>your usage description here</string>
```
# Android
* Change the minimum Android sdk version to 24 (or higher) in your android/app/build.gradle file.
```yaml
    minSdkVersion 24
```
Step 1. Ensure the following permission is present in your Android Manifest file, located in <project root>/android/app/src/main/AndroidManifest.xml:

```yaml
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

Step 2. Add the JitPack repository to your Android build file, located in <project root>/android/build.gradle:

```yaml
    allprojects {
    repositories {
    maven { url 'https://jitpack.io' }
    }
}
```
# Usage


[Example](https://github.com/hamzasidd3634/camera_filter/tree/master/lib/example)


To use this package:

* add the dependency to your [pubspec.yaml](https://github.com/hamzasidd3634/camera_filter/blob/master/example/pubspec.yaml) file.

```yaml
    dependencies:
      flutter:
        sdk: flutter
      camera_filters: <latest-version>
```

# ScreenShots

![1](https://user-images.githubusercontent.com/64409533/165637956-d82b2ff0-a570-49be-b48d-25e141b8bb37.png)
![4](https://user-images.githubusercontent.com/64409533/165637976-fb2df8c4-614b-4330-a136-1dc7043d87c0.png)



![2](https://user-images.githubusercontent.com/64409533/165637109-4a1bdf46-8e09-4dcd-88d5-989f48c4f650.png)
![3](https://user-images.githubusercontent.com/64409533/165637989-03d84eb5-2bd8-42c8-8525-9e7553d6d974.png)


# Video

* Camera
  ![pack](https://user-images.githubusercontent.com/64409533/165578953-cdfa1c9d-fe11-4454-a334-6cef3d85b078.gif)

* Video Recorder
  ![pack](https://user-images.githubusercontent.com/64409533/171751202-51dca2c6-7eb1-4abc-bdbc-e89336212d58.mp4)



# How to use


        import 'package:camera_filters/camera_filters.dart';
        import 'package:flutter/material.dart';
        
        void main() {
          WidgetsFlutterBinding.ensureInitialized();
          runApp(MyApp());
        }
        
        class MyApp extends StatefulWidget {
          @override
          _MyAppState createState() => _MyAppState();
        }
        
        class _MyAppState extends State<MyApp> {
          @override
          Widget build(BuildContext context) {
            return MaterialApp(
              home: Scaffold(
                body: CameraScreenPlugin(onDone: (value) {
                  /// value returns the picture path you can save here or navigate to some screen
                  print(value);
                },
        
                    /// value returns the video path you can save here or navigate to some screen
                    onVideoDone: (value) {
                  print(value);
                }
        
                    /// profileIconWidget: , if you want to add profile icon on camera you can your widget here
        
                    ///filterColor: ValueNotifier<Color>(Colors.transparent),  your first filter color when you open camera
        
                    /// filters: [],
                    ///you can pass your own list of colors like this List<Color> colors = [Colors.blue, Colors.blue, Colors.blue ..... Colors.blue]
                    ///make sure to pass transparent color to first index so the first index of list has no filter effect
                    ),
              ),
            );
          }
        }

