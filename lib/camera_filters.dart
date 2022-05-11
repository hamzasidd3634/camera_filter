// ignore_for_file: must_be_immutable

library camera_filters;

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_filters/src/edit_image_screen.dart';
import 'package:camera_filters/src/filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image/image.dart' as imglib;
import 'package:path_provider/path_provider.dart';

class CameraScreenPlugin extends StatefulWidget {
  /// this function will return the path of edited picture
  Function(dynamic)? onDone;

  /// list of filters
  List<Color>? filters;

  /// notify color to change
  ValueNotifier<Color>? filterColor;

  /// profile widget if you want to use profile widget on camera
  Widget? profileIconWidget;

  CameraScreenPlugin(
      {Key? key,
      this.onDone,
      this.filters,
      this.profileIconWidget,
      this.filterColor})
      : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreenPlugin> {
  /// Camera Controller
  late CameraController _controller;

  /// initializer of controller
  Future<void>? _initializeControllerFuture;

  /// local storage for mobile
  GetStorage sp = GetStorage();

  /// flash mode changer
  RxInt flashCount = 0.obs;

  /// condition check that picture is taken or not
  bool capture = false;

  /// camera list, this list will tell user that he/she is on front camera or back
  List<CameraDescription> cameras = [];

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
    super.initState();
    if (sp.read("flashCount") != null) {
      flashCount.value = sp.read("flashCount");
    }
    if (widget.filterColor != null) {
      widget.filterColor = ValueNotifier<Color>(Colors.transparent);
    }
    initCamera();
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

      /// if controller not initialized loader will show
      child: _initializeControllerFuture == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned.fill(
                  /// future builder for filters
                  child: FutureBuilder<void>(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        // If the Future is complete, display the preview.
                        return ValueListenableBuilder(
                            valueListenable: widget.filterColor ?? _filterColor,
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
                        // Otherwise, display a loading indicator.
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
                Positioned(
                  left: 0.0,
                  right: 0.0,
                  bottom: 0.0,
                  child: _buildFilterSelector(),
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
                      )
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  /// function will call when user tap on picture button
  void onTakePictureButtonPressed(context) {
    takePicture(context).then((String? filePath) async {
      if (_controller.value.isInitialized) {
        if (filePath != null) {
          Get.to(
            EditImageScreen(
              path: filePath,
              filter: ColorFilter.mode(
                  widget.filterColor == null
                      ? _filterColor.value
                      : widget.filterColor!.value,
                  BlendMode.softLight),
              onDone: widget.onDone,
            ),
          );
        }
        // });
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

    /// If the controller is updated then update the UI.
    /// 2
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
}
