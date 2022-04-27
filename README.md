# Camera Filters

Realtime Camera Filters


# Description

Realtime Camera Filters with image crop, text on image , text color and emojis. You can user your own custom color list to change filters

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

![pack](https://user-images.githubusercontent.com/64409533/165578953-cdfa1c9d-fe11-4454-a334-6cef3d85b078.gif)


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
                appBar: AppBar(
                  title: const Text('Camera'),
                ),
                body: CameraScreenPlugin(
                  onDone: (value) {
                    /// value returns the picture path you can save here or navigate to some screen
                    print(value);
                  },
        
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


