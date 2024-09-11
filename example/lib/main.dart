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
        body: CameraScreenPlugin(
          onDone: (value) {
            /// value returns the picture path you can save here or navigate to some screen
            print(value);
          },

<<<<<<< Updated upstream
            /// value returns the video path you can save here or navigate to some screen
            onVideoDone: (value) {
          print(value);
        }
=======
          /// time limit for video in seconds
          videoTimeLimit: 10,

          /// value returns the video path you can save here or navigate to some screen
          onVideoDone: (value) {
            print(value);
          },

          /// profileIconWidget: , if you want to add profile icon on camera you can your widget here
>>>>>>> Stashed changes

          ///filterColor: ValueNotifier<Color>(Colors.transparent),  your first filter color when you open camera

          /// filters: [],
          ///you can pass your own list of colors like this List<Color> colors = [Colors.blue, Colors.blue, Colors.blue ..... Colors.blue]
          ///make sure to pass transparent color to first index so the first index of list has no filter effect
        ),
      ),
    );
  }
}
