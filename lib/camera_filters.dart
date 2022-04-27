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
  Function(dynamic)? onDone;
  List<Color>? filters;
  ValueNotifier<Color>? filterColor;
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
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;
  GetStorage sp = GetStorage();
  RxInt flashCount = 0.obs;
  bool capture = false;
  List<CameraDescription> cameras = [];
  final _filters = [
    Colors.transparent,
    ...List.generate(
      Colors.primaries.length,
      (index) => Colors.primaries[(index * 4) % Colors.primaries.length],
    )
  ];
  final _filterColor = ValueNotifier<Color>(Colors.transparent);

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

  initCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller.initialize();
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
                      IconButton(onPressed: () {
                        if (flashCount.value == 0) {
                          flashCount.value = 1;
                          sp.write("flashCount", 1);
                          _controller.setFlashMode(FlashMode.torch);
                        } else if (flashCount.value == 1) {
                          flashCount.value = 2;
                          sp.write("flashCount", 2);
                          _controller.setFlashMode(FlashMode.auto);
                        } else {
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
                      IconButton(
                        icon: Icon(
                          Icons.cameraswitch,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          if (_controller.description.lensDirection ==
                              CameraLensDirection.front) {
                            CameraDescription selectedCamera = cameras[0];
                            _initCameraController(selectedCamera);
                          } else {
                            CameraDescription selectedCamera = cameras[1];
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

  void onTakePictureButtonPressed(context) {
    takePicture(context).then((String? filePath) async {
      if (_controller.value.isInitialized) {
        if (filePath != null) {
          Get.to(
            EditImageScreen(
              resource: filePath,
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

  Future<String> compressFile(File file, {takePicture = false}) async {
    File compressedFile = await FlutterNativeImage.compressImage(
      file.path,
      quality: 100,
    );
    List<int> imageBytes = await file.readAsBytes();

    imglib.Image? originalImage = imglib.decodeImage(imageBytes);

    imglib.Image? fixedImage;
    if (_controller.description.lensDirection == CameraLensDirection.front) {
      fixedImage = imglib.flipHorizontal(originalImage!);
    }

    File files = File(compressedFile.path);

    File fixedFile = await files.writeAsBytes(
      imglib.encodeJpg(originalImage!),
      flush: true,
    );
    return fixedFile.path;
  }

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

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

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

  Future _initCameraController(CameraDescription cameraDescription) async {
    if (_controller != null) {
      await _controller.dispose();
    }

    // 3
    _controller = CameraController(cameraDescription, ResolutionPreset.high);

    // If the controller is updated then update the UI.
    // 4
    _controller.addListener(() {
      // 5
      if (_controller.value.hasError) {
        print('Camera error ${_controller.value.errorDescription}');
      }
    });

    // 6
    try {
      await _controller.initialize();
    } on CameraException catch (e) {
      print(e);
    }
    setState(() {});
  }
}
// enum FlashMode {
//   /// Do not use the flash when taking a picture.
//   off,
//
//   /// Let the device decide whether to flash the camera when taking a picture.
//   auto,
//
//   /// Always use the flash when taking a picture.
//   always,
//
//   /// Turns on the flash light and keeps it on until switched off.
//   torch,
// }
