// ignore_for_file: must_be_immutable

library camera_filters;

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:camera_filters/src/edit_image_screen.dart';
import 'package:camera_filters/src/filters.dart';
import 'package:camera_filters/src/widgets/circularProgress.dart';
import 'package:camera_filters/videoPlayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image/image.dart' as imglib;
import 'package:path_provider/path_provider.dart';

class CameraScreenPlugin extends StatefulWidget {
  /// this function will return the path of edited picture
  Function(dynamic)? onDone;

  /// this function will return the path of edited video
  Function(dynamic)? onVideoDone;

  /// list of filters
  List<Color>? filters;

  /// notify color to change
  ValueNotifier<Color>? filterColor;

  ///circular gradient color
  List<Color>? gradientColors;

  /// profile widget if you want to use profile widget on camera
  Widget? profileIconWidget;

  CameraScreenPlugin(
      {Key? key,
      this.onDone,
      this.onVideoDone,
      this.filters,
      this.profileIconWidget,
      this.gradientColors,
      this.filterColor})
      : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreenPlugin>
    with TickerProviderStateMixin {
  ///animation controller for circular progress indicator
  late AnimationController controller;

  /// Camera Controller
  late CameraController _controller;

  /// initializer of controller
  Future<void>? _initializeControllerFuture;

  /// local storage for mobile
  GetStorage sp = GetStorage();

  /// flash mode changer
  RxInt flashCount = 0.obs;

  /// flash mode changer
  RxString time = "".obs;

  /// condition check that picture is taken or not
  bool capture = false;

  ///Timer initialize
  Timer? t;

  /// camera list, this list will tell user that he/she is on front camera or back
  List<CameraDescription> cameras = [];

  /// bool to change picture to video or video to picture
  RxBool? cameraChange = false.obs;

  AnimationController? _rotationController;
  double _rotation = 0;
  double _scale = 0.85;

  bool get _showWaves => !controller.isDismissed;

  void _updateRotation() {
    _rotation = (_rotationController!.value * 2) * pi;
    print("_rotation is $_rotation");
  }

  void _updateScale() {
    _scale = (controller.value * 0.2) + 0.85;
    print("scale is $_scale");
  }

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
    widget.filterColor == null
        ? _filterColor.value = value
        : widget.filterColor!.value = value;
  }

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3500),
    )..addListener(() async {
        setState(_updateScale);
      });
    _rotationController =
        AnimationController(vsync: this, duration: Duration(seconds: 5))
          ..addListener(() {
            setState(_updateRotation);
            if (_rotation > 5) {
              _rotationController!.reset();
              _rotationController!.forward();
            }
          });

    super.initState();
    if (sp.read("flashCount") != null) {
      flashCount.value = sp.read("flashCount");
    }
    if (widget.filterColor != null) {
      widget.filterColor = ValueNotifier<Color>(Colors.transparent);
    }
    initCamera();
  }

  ///timer Widget
  timer() {
    t = Timer.periodic(Duration(seconds: 1), (timer) {
      time.value = timer.tick.toString();
    });
  }

  ///timer function
  String formatHHMMSS(int seconds) {
    int hours = (seconds / 3600).truncate();
    seconds = (seconds % 3600).truncate();
    int minutes = (seconds / 60).truncate();

    String hoursStr = (hours).toString().padLeft(2, '0');
    String minutesStr = (minutes).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    if (hours == 0) {
      return "$minutesStr:$secondsStr";
    }

    return "$hoursStr:$minutesStr:$secondsStr";
  }

  ///this function will initialize camera
  initCamera() async {
    WidgetsFlutterBinding.ensureInitialized();

    /// this condition check that camera is available on your device
    cameras = await availableCameras();

    ///put camera in camera controller
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();

    ///set flash mode off by default
    _controller.setFlashMode(FlashMode.off);
    print(_initializeControllerFuture);
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: _initializeControllerFuture == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned.fill(
                  child: FutureBuilder<void>(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        /// If the Future is complete, display the preview.
                        return Obx(() {
                          if (cameraChange!.value == false) {
                            return ValueListenableBuilder(
                                valueListenable:
                                    widget.filterColor ?? _filterColor,
                                builder: (context, value, child) {
                                  return ColorFiltered(
                                    colorFilter: ColorFilter.mode(
                                        widget.filterColor == null
                                            ? _filterColor.value
                                            : widget.filterColor!.value,
                                        BlendMode.softLight),
                                    child: CameraPreview(_controller),
                                  );
                                });
                          } else {
                            return CameraPreview(_controller);
                          }
                        });
                      } else {
                        /// Otherwise, display a loading indicator.
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
                Positioned(
                  top: 50.0,
                  right: 10.0,
                  child: Obx(() => cameraChange!.value == false
                      ? Container()
                      : Text(
                          time.value == ""
                              ? ""
                              : formatHHMMSS(int.parse(time.value)),
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )),
                ),
                Positioned(
                  left: 0.0,
                  right: 0.0,
                  bottom: 0.0,
                  child: Obx(() {
                    if (cameraChange!.value == false) {
                      return _buildFilterSelector();
                    } else {
                      return videoRecordingWidget();
                    }
                  }),
                ),
                Positioned(
                  right: 10.0,
                  top: 30.0,
                  child: widget.profileIconWidget ?? Container(),
                ),
                Positioned(
                  left: 10.0,
                  top: 30.0,
                  child: Row(
                    children: [
                      /// icon for flash modes
                      IconButton(onPressed: () {
                        /// if flash count is zero flash will off
                        if (flashCount.value == 0) {
                          flashCount.value = 1;
                          sp.write("flashCount", 1);
                          _controller.setFlashMode(FlashMode.torch);

                          /// if flash count is one flash will on
                        } else if (flashCount.value == 1) {
                          flashCount.value = 2;
                          sp.write("flashCount", 2);
                          _controller.setFlashMode(FlashMode.auto);
                        }

                        /// if flash count is two flash will auto
                        else {
                          flashCount.value = 0;
                          sp.write("flashCount", 0);
                          _controller.setFlashMode(FlashMode.off);
                        }
                      }, icon: Obx(() {
                        return Icon(
                          flashCount.value == 0
                              ? Icons.flash_off
                              : flashCount.value == 1
                                  ? Icons.flash_on
                                  : Icons.flash_auto,
                          color: Colors.white,
                        );
                      })),
                      SizedBox(
                        width: 5,
                      ),

                      /// camera change to front or back
                      IconButton(
                        icon: Icon(
                          Icons.cameraswitch,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          if (_controller.description.lensDirection ==
                              CameraLensDirection.front) {
                            final CameraDescription selectedCamera = cameras[0];
                            _initCameraController(selectedCamera);
                          } else {
                            final CameraDescription selectedCamera = cameras[1];
                            _initCameraController(selectedCamera);
                          }
                        },
                      ),
                      SizedBox(
                        width: 5,
                      ),

                      Obx(() {
                        return IconButton(
                          icon: Icon(
                            cameraChange!.value == false
                                ? Icons.videocam
                                : Icons.camera,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (cameraChange!.value == false) {
                              cameraChange!(true);
                              _controller.prepareForVideoRecording();
                            } else {
                              cameraChange!(false);
                            }
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  flashCheck() {
    if (sp.read("flashCount") == 1) {
      _controller.setFlashMode(FlashMode.off);
    }
  }

  /// function will call when user tap on picture button
  void onTakePictureButtonPressed(context) {
    takePicture(context).then((String? filePath) async {
      if (_controller.value.isInitialized) {
        if (filePath != null) {
          flashCheck();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditImageScreen(
                      path: filePath,
                      filter: ColorFilter.mode(
                          widget.filterColor == null
                              ? _filterColor.value
                              : widget.filterColor!.value,
                          BlendMode.softLight),
                      onDone: widget.onDone,
                    )),
          ).then((value) {
            if (sp.read("flashCount") == 1) {
              _controller.setFlashMode(FlashMode.torch);
            }
          });
        }
      }
    });
  }

  /// compress the picture from bigger size to smaller
  Future<String> compressFile(File file, {takePicture = false}) async {
    final File compressedFile = await FlutterNativeImage.compressImage(
      file.path,
      quality: 100,
    );
    final List<int> imageBytes = await file.readAsBytes();

    imglib.Image? originalImage = imglib.decodeImage(imageBytes);

    if (_controller.description.lensDirection == CameraLensDirection.front) {
      originalImage = imglib.flipHorizontal(originalImage!);
    }

    final File files = File(compressedFile.path);

    final File fixedFile = await files.writeAsBytes(
      imglib.encodeJpg(originalImage!),
      flush: true,
    );
    return fixedFile.path;
  }

  /// function will call when user take picture
  Future<String> takePicture(context) async {
    if (!_controller.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: camera is not initialized')));
    }
    final String dirPath = getTemporaryDirectory().toString();
    String filePath = '$dirPath/${timestamp()}.jpg';

    try {
      await _controller.takePicture().then((file) async {
        filePath = await compressFile(File(file.path), takePicture: true);
      });
    } on CameraException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.description}')));
    }
    return filePath;
  }

  /// timestamp for image creation date
  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  /// widget will build the filter selector
  Widget _buildFilterSelector() {
    return FilterSelector(
      onFilterChanged: _onFilterChanged,
      filters: widget.filters ?? _filters,
      onTap: () {
        if (capture == false) {
          capture = true;
          onTakePictureButtonPressed(context);
          Future.delayed(Duration(seconds: 1), () {
            capture = false;
          });
        }
      },
    );
  }

  /// function initialize camera controller
  Future _initCameraController(CameraDescription cameraDescription) async {
    /// 1
    _controller = CameraController(cameraDescription, ResolutionPreset.high);

    /// 2
    /// If the controller is updated then update the UI.
    _controller.addListener(() {
      /// 3
      if (_controller.value.hasError) {
        print('Camera error ${_controller.value.errorDescription}');
      }
    });

    /// 4
    try {
      await _controller.initialize();
    } on CameraException catch (e) {
      print(e);
    }
    setState(() {});
  }

  ///video recording function
  Widget videoRecordingWidget() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onLongPress: () async {
          // if(controller.value ){

          await _controller.prepareForVideoRecording();
          await _controller.startVideoRecording();
          timer();
          controller.forward();
          _rotationController!.forward();
          // }
        },
        onLongPressEnd: (v) async {
          t!.cancel();
          time.value = "";
          controller.reset();
          _rotationController!.reset();
          final file = await _controller.stopVideoRecording();
          flashCheck();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VideoPlayer(
                      file.path,
                      onVideoDone: widget.onVideoDone,
                    )),
          ).then((value) {
            if (sp.read("flashCount") == 1) {
              _controller.setFlashMode(FlashMode.torch);
            }
          });
        },
        child: Container(
          width: 70,
          height: 70,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 10, minHeight: 10),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                if (_showWaves) ...[
                  Blob(
                      color: Color(0xff0092ff),
                      scale: _scale,
                      rotation: _rotation),
                  Blob(
                      color: Color(0xff4ac7b7),
                      scale: _scale,
                      rotation: _rotation * 2 - 30),
                  Blob(
                      color: Color(0xffa4a6f6),
                      scale: _scale,
                      rotation: _rotation * 3 - 45),
                ],
                Container(
                  constraints: BoxConstraints.expand(),
                  child: AnimatedSwitcher(
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                          color: Color(0xffd51820),
                          borderRadius: BorderRadius.circular(100)),
                    ),
                    duration: Duration(milliseconds: 300),
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
