// ignore_for_file: must_be_immutable

import 'dart:ui';

import 'package:better_player/better_player.dart';
import 'package:camera_filters/src/draw_image.dart';
import 'package:camera_filters/src/filters.dart';
import 'package:camera_filters/src/painter.dart';
import 'package:camera_filters/src/play.dart';
import 'package:camera_filters/src/widgets/_range_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tapioca/tapioca.dart';

class VideoPlayer extends StatefulWidget {
  String? video;
  Function(dynamic)? onVideoDone;

  VideoPlayer(this.video, {this.onVideoDone});

  @override
  State<VideoPlayer> createState() => _VideoPlayersState();
}

late BetterPlayerController _betterPlayerController;
late BetterPlayerDataSource _betterPlayerDataSource;

class _VideoPlayersState extends State<VideoPlayer> {
  late TextDelegate textDelegate;
  late final ValueNotifier<Controller> _controller;
  final TextEditingController _textEditingController = TextEditingController();
  double new_x = 0.0;
  double new_y = 0.0;
  double fontSize = 28;
  RxBool dragText = false.obs;
  RxBool textFieldBool = false.obs;
  Offset offset = Offset.zero;
  int? x;
  int? y;

  String text = '';
  RxInt colorValue = 0xff443a49.obs;
  Color fontColor = Colors.green;

  ///list of filters color
  final _filters = [
    Colors.transparent,
    ...List.generate(
      Colors.primaries.length,
      (index) => Colors.primaries[(index) % Colors.primaries.length],
    )
  ];

  ///filter color notifier
  final _filterColor = ValueNotifier<Color>(Colors.transparent);

  ///filter color change function
  void _onFilterChanged(Color value) {
    _filterColor.value = value;
  }

  /// widget will build the filter selector
  Widget _buildFilterSelector() {
    return FilterSelector(
      onVideoFilter: true,
      onFilterChanged: _onFilterChanged,
      filters: _filters,
      onTap: () {},
    );
  }

  @override
  void initState() {
    _controller = ValueNotifier(const Controller().copyWith(
        mode: PaintMode.freeStyle, strokeWidth: 2, color: Colors.green));
    textDelegate = TextDelegate();
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      aspectRatio: 0.5,
      fit: BoxFit.fill,
      autoPlay: true,
      looping: true,
      subtitlesConfiguration: //a == null?BetterPlayerSubtitlesConfiguration():
          BetterPlayerSubtitlesConfiguration(fontColor: Colors.transparent),
      controlsConfiguration: BetterPlayerControlsConfiguration(
          iconsColor: Colors.transparent,
          textColor: Colors.transparent,
          progressBarPlayedColor: Colors.transparent,
          progressBarBackgroundColor: Colors.transparent,
          progressBarBufferedColor: Colors.transparent,
          progressBarHandleColor: Colors.transparent),
      expandToFill: true,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp
      ],
    );
    _betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.file,
      widget.video!,
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(_betterPlayerDataSource);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: AspectRatio(
                aspectRatio: 0.5,
                child: ValueListenableBuilder(
                    valueListenable: _filterColor,
                    builder: (context, value, child) {
                      return ColorFiltered(
                          colorFilter: ColorFilter.mode(
                              _filterColor.value, BlendMode.softLight),
                          child: BetterPlayer(
                              controller: _betterPlayerController));
                    })),
          ),
          _buildFilterSelector(),
          Obx(() {
            if (dragText.isFalse) {
              return positionedText();
            } else {
              return positionedText();
            }
          }),
          Obx(() {
            if (textFieldBool.isFalse) {
              return Container();
            } else {
              return textField(context);
            }
          }),
          Positioned(
              top: 40,
              right: 10,
              child: Column(
                children: [
                  PopupMenuButton(
                    tooltip: textDelegate.changeBrushSize,
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    icon: Icon(Icons.format_size, color: Colors.white),
                    itemBuilder: (_) => [_showTextSlider()],
                  ),
                  ValueListenableBuilder<Controller>(
                      valueListenable: _controller,
                      builder: (_, controller, __) {
                        return IconButton(
                          icon: Icon(
                            Icons.color_lens_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            colorPicker(controller);
                          },
                        );
                      }),
                  IconButton(
                      icon: const Icon(
                        Icons.text_format,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        textFieldBool(!textFieldBool.value);
                      }),
                ],
              )),
          Positioned(
              bottom: 10,
              right: 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Material(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      print("clicked!");
                      var tempDir = await getTemporaryDirectory();
                      final path =
                          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}result.mp4';
                      print(tempDir);

                      var dx = offset.dx.isNegative
                          ? (-offset.dx +
                                  (MediaQuery.of(context).size.width / 10))
                              .floor()
                          : (offset.dx +
                                  (MediaQuery.of(context).size.width / 10))
                              .floor();
                      var dy = offset.dy.isNegative
                          ? (-offset.dy +
                                  (MediaQuery.of(context).size.height / 100))
                              .floor()
                          : (offset.dy +
                                  (MediaQuery.of(context).size.height / 100))
                              .floor();
                      print(xPos);
                      print(yPos);
                      print("maakichu");
                      print(_filterColor.value.value);
                      String command =
                          "-y, -i, ${widget.video!}, -filter_complex, [0:v][1:v]overlay=main_w-overlay_w-5:5,drawtext=fontsize=${fontSize.floor()}:x=${offset.dx}:y=${offset.dy}:text=$text:enable='between(t\,1\,2)', -crf, 27, -preset, veryfast, -c:v, libx264, -r, 30, $path";
                      try {
                        var a = 1.5 * int.parse(xPos.toString().split(".")[0]);
                        var b = 1.5 * int.parse(yPos.toString().split(".")[0]);
                        final tapiocaBalls = [
                          // TapiocaBall.filterFromColor(
                          //     Color(_filterColor.value.value)),
                          TapiocaBall.textOverlay(
                              text,
                              int.parse(a.toString().split(".")[0]),
                              int.parse(b.toString().split(".")[0]),
                              60,
                              Colors.white),
                        ];

                        final cup = Cup(Content(widget.video!), tapiocaBalls);
                        cup.suckUp(path).then((_) async {
                          print("finished");
                          GallerySaver.saveVideo(path).then((bool? success) {
                            print(success.toString());
                          });
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Player(
                                      path,
                                    )),
                          );
                          // widget.onVideoDone!.call(path);
                        });
                      } on PlatformException {
                        print("error!!!!");
                      }
                    },
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                          color: Color(0xffd51820),
                          borderRadius: BorderRadius.circular(60)),
                      child: Center(
                        child: Icon(Icons.send),
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  PopupMenuItem _showTextSlider() {
    return PopupMenuItem(
      enabled: false,
      child: SizedBox(
        width: double.maxFinite,
        child: ValueListenableBuilder<Controller>(
          valueListenable: _controller,
          builder: (_, ctrl, __) {
            return FontRangedSlider(
                value: ctrl.fontSize,
                onChanged: (value) {
                  _controller.value = ctrl.copyWith(fontSize: value);
                  fontSize = value;
                  setState(() {});
                });
          },
        ),
      ),
    );
  }

  colorPicker(controller) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Pick a color!'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: Color(controller.color.value),
                onColorChanged: (color) {
                  _controller.value = controller.copyWith(color: color);
                  colorValue.value = color.value;
                  setState(() {});
                  // Navigator.pop(context);
                },
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Widget textField(context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                      cursorColor: Colors.white,
                      autofocus: true,
                      controller: _textEditingController,
                      style: TextStyle(color: Colors.white, fontSize: 30),
                      decoration: InputDecoration(border: InputBorder.none))),
            ),
            IconButton(
                onPressed: () {
                  if (_textEditingController.text.isNotEmpty) {
                    text = _textEditingController.text;
                    textFieldBool.value = false;
                    dragText(!dragText.value);
                  }
                },
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                ))
          ],
        ),
      ),
    );
  }

  var xPos = 30.0;
  var yPos = 30.0;
  final width = 100.0;
  final height = 100.0;
  bool _dragging = false;

  /// Is the point (x, y) inside the rect?
  bool _insideRect(double x, double y) =>
      x >= xPos && x <= xPos + width && y >= yPos && y <= yPos + height;
  Widget positionedText() {
    double baseWidth = window.physicalSize.width;
    double baseHeight = window.physicalSize.height;

    double newWidth = MediaQuery.of(context).size.width;
    double newHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onPanStart: (details) => _dragging = _insideRect(
        details.globalPosition.dx,
        details.globalPosition.dy,
      ),
      onPanEnd: (details) {
        _dragging = false;
      },
      onPanUpdate: (details) {
        if (_dragging) {
          setState(() {
            xPos += details.delta.dx;
            yPos += details.delta.dy;
          });
        }
      },
      child: CustomPaint(
        painter: MyPainter(xPos, yPos, text),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          //   child: Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: Center(
          //       child: Obx(() => Text(text,
          //           textAlign: TextAlign.center,
          //           style: TextStyle(
          //               fontWeight: FontWeight.bold,
          //               fontSize: fontSize,
          //               color: Color(colorValue.value)))),
          //     ),
          //   ),
        ),
      ),
    );
  }
}
// Positioned(
//   left: offset.dx,
//   top: offset.dy,
//   child: GestureDetector(
//     onPanUpdate: (details) {
//       offset = Offset(
//           offset.dx + details.delta.dx, offset.dy + details.delta.dy);
//       new_x = offset.dx *
//           (baseWidth / newWidth); //(baseWidth * offset.dx) / 480;
//       new_y = offset.dy *
//           (baseHeight / newHeight); //(baseWidth * offset.dy) / 960;
//       print("new x ${offset.distance}");
//       print("new y ${offset.dx / offset.direction}");
//       print(MediaQueryData.fromWindow(window).size.width);
//       print(MediaQueryData.fromWindow(window).size.height);
//
//       var xcan = ((MediaQueryData.fromWindow(window).size.width));
//       var ycan = (MediaQueryData.fromWindow(window).size.height);
//       // offset = details.delta;
//       // var A = Offset.fromDirection(offset.direction);
//       var xDistance =
//           sqrt(((xcan - details.delta.dx) * (xcan - details.delta.dx)));
//       var yDistance =
//           sqrt(((ycan - details.delta.dy) * (ycan - details.delta.dy)));
//       var distance = sqrt(
//           ((xcan - details.delta.dx) * (xcan - details.delta.dx)) +
//               ((ycan - details.delta.dy) * (ycan - details.delta.dy)));
//       print(details.delta);
//       print(distance);
//       print(xDistance);
//       print(yDistance);
//       var y = (sin(pi / 180) * distance);
//       var x = (cos(pi / 180) * distance);
//       print(x);
//       print(y);
//       // this.x = x;
//       // this.y = y;
//       // offset = Offset(y.toDouble(), x.toDouble());
//       print("asdasdads");
//
//       dragText(!dragText.value);
//       // print("new x ${new_x}");
//       // print("new y ${new_y}");
//       // print(
//       //     "new x ${window.physicalSize.width / window.}");
//       // print("new y ${new_y}");
//       // print(offset.dx.isNegative ? offset.dx * -2 : offset.dx * 2);
//       dragText(!dragText.value);
//     },
//     // child:
//     //   Draggable(
//     // onDragEnd: (details) {
//     //
//     // },
//     // feedback: SizedBox(
//     //   width: MediaQuery.of(context).size.width,
//     //   height: MediaQuery.of(context).size.height,
//     //   child: Padding(
//     //     padding: const EdgeInsets.all(8.0),
//     //     child: Center(
//     //       child: Obx(() => Text(text,
//     //           textAlign: TextAlign.center,
//     //           style: TextStyle(
//     //               fontWeight: FontWeight.bold,
//     //               fontSize: fontSize,
//     //               color: Color(colorValue.value)))),
//     //     ),
//     //   ),
//     // ),
//     child: SizedBox(
//       width: MediaQuery.of(context).size.width,
//       height: MediaQuery.of(context).size.height,
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Center(
//           child: Obx(() => Text(text,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: fontSize,
//                   color: Color(colorValue.value)))),
//         ),
//       ),
//     ),
//   )
//   // ),
//   );
// }
// }

class MyPainter extends CustomPainter {
  //         <-- CustomPainter class

  MyPainter(this.xPos, this.yPos, this.text);
  final double xPos;
  final double yPos;
  final String text;
  @override
  void paint(Canvas canvas, Size size) {
    //                                             <-- Insert your painting code here.
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 30,
    );
    final textSpan = TextSpan(
      text: '$text',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    final xCenter = (size.width - textPainter.width) / 2;
    final yCenter = (size.height - textPainter.height) / 2;
    final offset = Offset(xPos, yPos);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}
