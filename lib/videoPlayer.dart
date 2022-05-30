// ignore_for_file: must_be_immutable

import 'package:better_player/better_player.dart';
import 'package:camera_filters/src/draw_image.dart';
import 'package:camera_filters/src/painter.dart';
import 'package:camera_filters/src/widgets/_range_slider.dart';
import 'package:camera_filters/src/widgets/progressDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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
  double fontSize = 30;
  RxBool dragText = false.obs;
  RxBool textFieldBool = false.obs;
  Offset offset = Offset.zero;
  int? x;
  int? y;

  String text = '';
  RxInt colorValue = 0xFFFFFFFF.obs;

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

  ProgressDialog? progressDialog;

  /// widget will build the filter selector
  Widget _buildFilterSelector() {
    // return FilterSelector(
    //   onVideoFilter: true,
    //   onFilterChanged: _onFilterChanged,
    //   filters: _filters,
    //   onTap: () {},
    // );
    int index = 0;
    return Center(
      child: Container(
        height: 50,
        child: PageView.builder(
          itemCount: _filters.length,
          onPageChanged: (i) {
            index = i;
            print("index is " + index.toString());
          },
          physics: NeverScrollableScrollPhysics(),
          // pageSnapping: ,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, position) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    GestureDetector(
                        onTap: () {
                          if (index != 0) {
                            _onFilterChanged(_filters[index - 1]);
                            index = index - 1;
                          }
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        )),
                    Spacer(),
                    GestureDetector(
                        onTap: () {
                          if (index != _filters.length - 1) {
                            _onFilterChanged(_filters[index + 1]);
                            index = index + 1;
                          }
                        },
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                        )),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    progressDialog = ProgressDialog(context);
    _controller = ValueNotifier(const Controller().copyWith(
        mode: PaintMode.freeStyle, strokeWidth: 2, color: Colors.white));
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
          Obx(() {
            if (dragText.isFalse) {
              return Container();
            } else {
              return positionedText();
            }
          }),
          _buildFilterSelector(),
          // Obx(() {
          //   if (textFieldBool.isFalse) {
          //     return Container();
          //   } else {
          //     return textField(context);
          //   }
          // }),
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
                        showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            enableDrag: true,
                            isDismissible: true,
                            builder: (builder) {
                              return textField(context);
                            });
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
                      var tempDir = await getTemporaryDirectory();
                      final path =
                          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}result.mp4';

                      try {
                        var a = 1.7 * int.parse(xPos.toString().split(".")[0]);
                        var b = 1.7 * int.parse(yPos.toString().split(".")[0]);

                        if (text == "" && _filterColor.value.value == 0) {
                          widget.onVideoDone!.call(widget.video);
                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => Player(
                          //             widget.video,
                          //           )),
                          // );
                        } else if (text == "" &&
                            _filterColor.value.value != 0) {
                          final tapiocaBalls = [
                            TapiocaBall.filterFromColor(
                                Color(_filterColor.value.value)),
                          ];
                          makeVideo(tapiocaBalls, path);
                        } else if (text != "" &&
                            _filterColor.value.value == 0) {
                          final tapiocaBalls = [
                            TapiocaBall.textOverlay(
                                text,
                                int.parse(a.toString().split(".")[0]),
                                int.parse(b.toString().split(".")[0]),
                                (fontSize * 2).toInt(),
                                Color(colorValue.value))
                          ];
                          makeVideo(tapiocaBalls, path);
                        } else {
                          final tapiocaBalls = [
                            TapiocaBall.filterFromColor(
                                Color(_filterColor.value.value)),
                            TapiocaBall.textOverlay(
                                text,
                                int.parse(a.toString().split(".")[0]),
                                int.parse(b.toString().split(".")[0]),
                                (fontSize * 2).toInt(),
                                Color(colorValue.value))
                          ];
                          makeVideo(tapiocaBalls, path);
                        }
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

  makeVideo(tapiocaBalls, path) {
    progressDialog!.show();
    final cup = Cup(Content(widget.video!), tapiocaBalls);
    cup.suckUp(path).then((_) async {
      print("finished");
      progressDialog!.hide();
      widget.onVideoDone!.call(path);
      // GallerySaver.saveVideo(path).then((bool? success) {
      //   print(success.toString());
      // });
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //       builder: (context) => Player(
      //             path,
      //           )),
      // );
      // widget.onVideoDone!.call(path);
    });
  }

  PopupMenuItem _showTextSlider() {
    return PopupMenuItem(
      enabled: false,
      child: SizedBox(
        width: double.maxFinite,
        child: ValueListenableBuilder<Controller>(
          valueListenable: _controller,
          builder: (_, ctrl, __) {
            return FontVideoRangedSlider(
                value: fontSize,
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
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 10,
          right: 10),
      child: Container(
        height: 55,
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0.0, horizontal: 3),
                  child: TextFormField(
                      cursorColor: Colors.black,
                      autofocus: true,
                      controller: _textEditingController,
                      style: TextStyle(color: Colors.black, fontSize: 25),
                      decoration: InputDecoration(border: InputBorder.none))),
            ),
            IconButton(
                onPressed: () {
                  if (_textEditingController.text.isNotEmpty) {
                    text = _textEditingController.text;
                    Get.close(1);
                    dragText(true);
                  }
                },
                icon: const Icon(
                  Icons.send,
                  color: Colors.black,
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

  // bool _dragging = false;
  //
  // /// Is the point (x, y) inside the rect?
  // bool _insideRect(double x, double y) =>
  //     x >= xPos && x <= xPos + width && y >= yPos && y <= yPos + height;

  Widget positionedText() {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          xPos += details.delta.dx;
          yPos += details.delta.dy;
        });
      },
      child: Obx(() {
        return CustomPaint(
          willChange: true,
          size: Size(
            MediaQuery.of(context).size.width,
            300,
          ),
          painter:
              MyPainter(xPos, yPos, text, Color(colorValue.value), fontSize),
          child: Container(),
        );
      }),
    );
  }
}

class MyPainter extends CustomPainter {
  MyPainter(this.xPos, this.yPos, this.text, this.color, this.fontSize);

  double? xPos;
  double? yPos;
  double? fontSize;
  String? text;
  Color? color;
  Offset? offset;
  TextPainter? textPainter;
  TextSpan? textSpan;
  TextStyle? textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    //                                             <-- Insert your painting code here.
    textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
    );
    textSpan = TextSpan(
      text: '$text',
      style: textStyle,
    );
    textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter!.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    offset = Offset(xPos!, yPos!);
    textPainter!.paint(canvas, offset!);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}
