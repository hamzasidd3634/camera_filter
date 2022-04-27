# Camera Filters

Realtime Camera Filters

# ScreenShots


![Screenshot_1651076763](https://user-images.githubusercontent.com/64409533/165566964-570c898d-2aa8-4de0-a471-4e09e68835d1.png)![Screenshot_1651076769](https://user-images.githubusercontent.com/64409533/165567013-9232c056-ba5c-443a-8fe3-8ace24e50a20.png)![Screenshot_1651076772](https://user-images.githubusercontent.com/64409533/165567026-c590b226-ab32-499a-a22e-3215fbd049d3.png)![Screenshot_1651076795](https://user-images.githubusercontent.com/64409533/165567031-04511bba-9db4-4f69-a684-de584d2bd7b0.png)

# Video

![pack](https://user-images.githubusercontent.com/64409533/165578953-cdfa1c9d-fe11-4454-a334-6cef3d85b078.gif)

# Usage

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


