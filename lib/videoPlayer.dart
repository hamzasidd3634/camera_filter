// ignore_for_file: must_be_immutable

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

  double fontSize = 28;
  RxBool dragText = false.obs;
  RxBool textFieldBool = false.obs;
  Offset offset = Offset.zero;
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
                      print(dy);
                      print(dx);
                      String command =
                          "-y, -i, ${widget.video!}, -filter_complex, [0:v][1:v]overlay=main_w-overlay_w-5:5,drawtext=fontsize=${fontSize.floor()}:x=${offset.dx}:y=${offset.dy}:text=$text:enable='between(t\,1\,2)', -crf, 27, -preset, veryfast, -c:v, libx264, -r, 30, $path";
                      try {
                        final tapiocaBalls = [
                          TapiocaBall.filterFromColor(
                              Color(_filterColor.value.value)),
                          TapiocaBall.textOverlay(text, 300, 700,
                              fontSize.floor(), Color(colorValue.value)),
                        ];
                        final cup = Cup(Content(widget.video!), tapiocaBalls);
                        cup.suckUp(path).then((_) async {
                          print("finished");
                          GallerySaver.saveVideo(path).then((bool? success) {
                            print(success.toString());
                          });
                          Navigator.push(
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

  Widget positionedText() {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: GestureDetector(
          onPanUpdate: (details) {
            offset = Offset(
                offset.dx + details.delta.dx, offset.dy + details.delta.dy);
            // print(offset.dx.isNegative ? offset.dx * -2 : offset.dx * 2);
            print(offset.dy.isNegative
                ? -offset.dy + (MediaQuery.of(context).size.height / 100)
                : offset.dy + (MediaQuery.of(context).size.height / 100));
            dragText(!dragText.value);
          },
          child: SizedBox(
            width: 300,
            height: 300,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Obx(() => Text(text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize,
                        color: Color(colorValue.value)))),
              ),
            ),
          )),
    );
  }
}
