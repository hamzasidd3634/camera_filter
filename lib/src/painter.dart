// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera_filters/src/draw_image.dart';
import 'package:camera_filters/src/transformer.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

import 'widgets/_range_slider.dart';
import 'widgets/_text_dialog.dart';

///[ImagePainter] widget.
///this widget could call on any image
///you can use this widget for image editing purpose
///draw some paint on your image
///write some text on your image
///crop your image
///font size increase or decrease
///stroke with increase or decrease
class ImagePainter extends StatefulWidget {
  ImagePainter._(
      {Key? key,
      this.assetPath,
      this.networkUrl,
      this.byteArray,
      this.file,
      this.height,
      this.width,
      this.placeHolder,
      this.isScalable,
      this.brushIcon,
      this.clearAllIcon,
      this.colorIcon,
      this.undoIcon,
      this.isSignature = false,
      this.signatureBackgroundColor,
      this.colors,
      this.initialPaintMode,
      this.initialStrokeWidth,
      this.initialColor,
      this.onColorChanged,
      this.onStrokeWidthChanged,
      this.onFontSizeChanged,
      this.onPaintModeChanged,
      this.filter,
      this.onDone,
      this.textDelegate})
      : super(key: key);

  ///Constructor for loading image from network url.
  factory ImagePainter.network(
    ///url or image

    String url, {
    required Key key,

    ///image height

    double? height,

    ///image width

    double? width,

    /// placeholder

    Widget? placeholderWidget,

    /// scalable condition

    bool? scalable,

    ///list of colors

    List<Color>? colors,

    /// brush icon widget

    Widget? brushIcon,

    ///undo icon widget

    Widget? undoIcon,

    ///clear all icon

    Widget? clearAllIcon,

    /// clear icon

    Widget? colorIcon,

    ///initial paint mode

    PaintMode? initialPaintMode,

    ///initial stroke width

    double? initialStrokeWidth,

    ///initial color

    Color? initialColor,

    ///paint mode notifier

    ValueChanged<PaintMode>? onPaintModeChanged,

    ///color change notifier

    ValueChanged<Color>? onColorChanged,

    ///stroke width notifier

    ValueChanged<double>? onStrokeWidthChanged,

    ///font size change notifier

    ValueChanged<double>? onFontSizeChanged,

    ///text delegate

    TextDelegate? textDelegate,
  }) {
    return ImagePainter._(
      key: key,
      networkUrl: url,
      height: height,
      width: width,
      placeHolder: placeholderWidget,
      isScalable: scalable,
      colors: colors,
      brushIcon: brushIcon,
      undoIcon: undoIcon,
      colorIcon: colorIcon,
      clearAllIcon: clearAllIcon,
      initialPaintMode: initialPaintMode,
      initialColor: initialColor,
      initialStrokeWidth: initialStrokeWidth,
      onPaintModeChanged: onPaintModeChanged,
      onColorChanged: onColorChanged,
      onStrokeWidthChanged: onStrokeWidthChanged,
      onFontSizeChanged: onFontSizeChanged,
      textDelegate: textDelegate,
    );
  }

  ///Constructor for loading image from assetPath.
  factory ImagePainter.asset(
    ///url or image
    String path, {
    required Key key,

    ///image height
    double? height,

    ///image width
    double? width,

    /// placeholder
    bool? scalable,

    /// scalable condition
    Widget? placeholderWidget,

    ///list of colors
    List<Color>? colors,

    /// brush icon widget
    Widget? brushIcon,

    ///undo icon widget
    Widget? undoIcon,

    ///clear all icon
    Widget? clearAllIcon,

    /// clear icon
    Widget? colorIcon,

    ///initial paint mode
    PaintMode? initialPaintMode,

    ///initial stroke width
    double? initialStrokeWidth,

    ///initial color
    Color? initialColor,

    ///paint mode notifier
    ValueChanged<PaintMode>? onPaintModeChanged,

    ///color change notifier
    ValueChanged<Color>? onColorChanged,

    ///stroke width notifier
    ValueChanged<double>? onStrokeWidthChanged,

    ///font size change notifier
    ValueChanged<double>? onFontSizeChanged,

    ///text delegate
    TextDelegate? textDelegate,
  }) {
    return ImagePainter._(
      key: key,
      assetPath: path,
      height: height,
      width: width,
      isScalable: scalable ?? false,
      placeHolder: placeholderWidget,
      colors: colors,
      brushIcon: brushIcon,
      undoIcon: undoIcon,
      colorIcon: colorIcon,
      clearAllIcon: clearAllIcon,
      initialPaintMode: initialPaintMode,
      initialColor: initialColor,
      initialStrokeWidth: initialStrokeWidth,
      onPaintModeChanged: onPaintModeChanged,
      onColorChanged: onColorChanged,
      onStrokeWidthChanged: onStrokeWidthChanged,
      onFontSizeChanged: onFontSizeChanged,
      textDelegate: textDelegate,
    );
  }

  ///Constructor for loading image from [File].
  factory ImagePainter.file(
    File file, {
    required Key key,
    double? height,
    double? width,
    ColorFilter? filter,
    Function? onDone,
    bool? scalable,
    Widget? placeholderWidget,
    List<Color>? colors,
    Widget? brushIcon,
    Widget? undoIcon,
    Widget? clearAllIcon,
    Widget? colorIcon,
    PaintMode? initialPaintMode,
    double? initialStrokeWidth,
    Color? initialColor,
    ValueChanged<PaintMode>? onPaintModeChanged,
    ValueChanged<Color>? onColorChanged,
    ValueChanged<double>? onStrokeWidthChanged,
    ValueChanged<double>? onFontSizeChanged,
    TextDelegate? textDelegate,
  }) {
    return ImagePainter._(
      key: key,
      file: file,
      height: height,
      width: width,
      filter: filter,
      placeHolder: placeholderWidget,
      colors: colors,
      onDone: onDone,
      isScalable: scalable ?? false,
      brushIcon: brushIcon,
      undoIcon: undoIcon,
      colorIcon: colorIcon,
      clearAllIcon: clearAllIcon,
      initialPaintMode: initialPaintMode,
      initialColor: initialColor,
      initialStrokeWidth: initialStrokeWidth,
      onPaintModeChanged: onPaintModeChanged,
      onColorChanged: onColorChanged,
      onStrokeWidthChanged: onStrokeWidthChanged,
      onFontSizeChanged: onFontSizeChanged,
      textDelegate: textDelegate,
    );
  }

  ///Constructor for loading image from memory.
  factory ImagePainter.memory(
    Uint8List byteArray, {
    required Key key,
    double? height,
    double? width,
    bool? scalable,
    Widget? placeholderWidget,
    List<Color>? colors,
    Widget? brushIcon,
    Widget? undoIcon,
    Widget? clearAllIcon,
    Widget? colorIcon,
    PaintMode? initialPaintMode,
    double? initialStrokeWidth,
    Color? initialColor,
    ValueChanged<PaintMode>? onPaintModeChanged,
    ValueChanged<Color>? onColorChanged,
    ValueChanged<double>? onStrokeWidthChanged,
    ValueChanged<double>? onFontSizeChanged,
    TextDelegate? textDelegate,
  }) {
    return ImagePainter._(
      key: key,
      byteArray: byteArray,
      height: height,
      width: width,
      placeHolder: placeholderWidget,
      isScalable: scalable ?? false,
      colors: colors,
      brushIcon: brushIcon,
      undoIcon: undoIcon,
      colorIcon: colorIcon,
      clearAllIcon: clearAllIcon,
      initialPaintMode: initialPaintMode,
      initialColor: initialColor,
      initialStrokeWidth: initialStrokeWidth,
      onPaintModeChanged: onPaintModeChanged,
      onColorChanged: onColorChanged,
      onStrokeWidthChanged: onStrokeWidthChanged,
      onFontSizeChanged: onFontSizeChanged,
      textDelegate: textDelegate,
    );
  }

  ///Constructor for signature painting.
  factory ImagePainter.signature({
    required Key key,
    Color? signatureBgColor,
    double? height,
    double? width,
    List<Color>? colors,
    Widget? brushIcon,
    Widget? undoIcon,
    Widget? clearAllIcon,
    Widget? colorIcon,
    ValueChanged<PaintMode>? onPaintModeChanged,
    ValueChanged<Color>? onColorChanged,
    ValueChanged<double>? onStrokeWidthChanged,
    ValueChanged<double>? onFontSizeChanged,
    TextDelegate? textDelegate,
  }) {
    return ImagePainter._(
      key: key,
      height: height,
      width: width,
      isSignature: true,
      isScalable: false,
      colors: colors,
      signatureBackgroundColor: signatureBgColor ?? Colors.white,
      brushIcon: brushIcon,
      undoIcon: undoIcon,
      colorIcon: colorIcon,
      clearAllIcon: clearAllIcon,
      onPaintModeChanged: onPaintModeChanged,
      onColorChanged: onColorChanged,
      onStrokeWidthChanged: onStrokeWidthChanged,
      onFontSizeChanged: onFontSizeChanged,
      textDelegate: textDelegate,
    );
  }

  ///Only accessible through [ImagePainter.network] constructor.
  final String? networkUrl;

  ///Only accessible through [ImagePainter.memory] constructor.
  final Uint8List? byteArray;

  ///Only accessible through [ImagePainter.file] constructor.
  File? file;

  ///Only accessible through [ImagePainter.asset] constructor.
  final String? assetPath;

  ///Height of the Widget. Image is subjected to fit within the given height.
  final double? height;

  ///Width of the widget. Image is subjected to fit within the given width.
  final double? width;
  final Function? onDone;

  ///Widget to be shown during the conversion of provided image to [ui.Image].
  final Widget? placeHolder;

  ///Defines whether the widget should be scaled or not. Defaults to [false].
  final bool? isScalable;
  final ColorFilter? filter;

  ///Flag to determine signature or image;
  final bool isSignature;

  ///Signature mode background color
  final Color? signatureBackgroundColor;

  ///List of colors for color selection
  ///If not provided, default colors are used.
  final List<Color>? colors;

  ///Icon Widget of strokeWidth.
  final Widget? brushIcon;

  ///Widget of Color Icon in control bar.
  final Widget? colorIcon;

  ///Widget for Undo last action on control bar.
  final Widget? undoIcon;

  ///Widget for clearing all actions on control bar.
  final Widget? clearAllIcon;

  ///Initial PaintMode.
  final PaintMode? initialPaintMode;

  ///the initial stroke width
  final double? initialStrokeWidth;

  ///the initial color
  final Color? initialColor;

  /// change color listener
  final ValueChanged<Color>? onColorChanged;

  /// stroke width listener
  final ValueChanged<double>? onStrokeWidthChanged;

  /// font size change listener
  final ValueChanged<double>? onFontSizeChanged;

  /// paint mode change listener
  final ValueChanged<PaintMode>? onPaintModeChanged;

  ///the text delegate
  final TextDelegate? textDelegate;

  @override
  ImagePainterState createState() => ImagePainterState();
}

///
class ImagePainterState extends State<ImagePainter> {
  final _repaintKey = GlobalKey();
  ui.Image? _image;
  double fontSize = 28;
  Color fontColor = Colors.green;
  bool _inDrag = false;
  final _paintHistory = <PaintInfo>[];
  final _points = <Offset?>[];
  late final ValueNotifier<Controller> _controller;
  late final ValueNotifier<bool> _isLoaded;
  late final TextEditingController _textController;
  Offset? _start, _end;
  File? capturedFile;

  final GlobalKey _globalKey = GlobalKey();
  int _strokeMultiplier = 1;
  late TextDelegate textDelegate;
  void initState() {
    super.initState();
    _isLoaded = ValueNotifier<bool>(false);
    _resolveAndConvertImage();

    _controller = ValueNotifier(const Controller().copyWith(
        mode: widget.initialPaintMode,
        strokeWidth: widget.initialStrokeWidth,
        color: widget.initialColor));

    _textController = TextEditingController();
    textDelegate = widget.textDelegate ?? TextDelegate();
  }

  @override
  void dispose() {
    _controller.dispose();
    _isLoaded.dispose();
    _textController.dispose();
    super.dispose();
  }

  Paint get _painter => Paint()
    ..color = _controller.value.color
    ..strokeWidth = _controller.value.strokeWidth * _strokeMultiplier
    ..style = _controller.value.mode == PaintMode.freeStyle
        ? PaintingStyle.stroke
        : _controller.value.paintStyle;

  ///Converts the incoming image type from constructor to [ui.Image]
  Future<void> _resolveAndConvertImage() async {
    if (widget.networkUrl != null) {
      _image = await _loadNetworkImage(widget.networkUrl!);
      if (_image == null) {
        throw ("${widget.networkUrl} couldn't be resolved.");
      } else {
        _setStrokeMultiplier();
      }
    } else if (widget.assetPath != null) {
      final img = await rootBundle.load(widget.assetPath!);
      _image = await _convertImage(Uint8List.view(img.buffer));
      if (_image == null) {
        throw ("${widget.assetPath} couldn't be resolved.");
      } else {
        _setStrokeMultiplier();
      }
    } else if (widget.file != null) {
      final img = await widget.file!.readAsBytes();
      _image = await _convertImage(img);
      if (_image == null) {
        throw ("Image couldn't be resolved from provided file.");
      } else {
        _setStrokeMultiplier();
      }
    } else if (widget.byteArray != null) {
      _image = await _convertImage(widget.byteArray!);
      if (_image == null) {
        throw ("Image couldn't be resolved from provided byteArray.");
      } else {
        _setStrokeMultiplier();
      }
    } else {
      _isLoaded.value = true;
    }
  }

  ///Dynamically sets stroke multiplier on the basis of widget size.
  ///Implemented to avoid thin stroke on high res images.
  _setStrokeMultiplier() {
    if ((_image!.height + _image!.width) > 1000) {
      _strokeMultiplier = (_image!.height + _image!.width) ~/ 1000;
    }
  }

  ///Completer function to convert asset or file image to [ui.Image] before drawing on custompainter.
  Future<ui.Image> _convertImage(Uint8List img) async {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(img, (image) {
      _isLoaded.value = true;
      return completer.complete(image);
    });
    return completer.future;
  }

  ///Completer function to convert network image to [ui.Image] before drawing on custompainter.
  Future<ui.Image> _loadNetworkImage(String path) async {
    final completer = Completer<ImageInfo>();
    var img = NetworkImage(path);
    img.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((info, _) => completer.complete(info)));
    final imageInfo = await completer.future;
    _isLoaded.value = true;
    return imageInfo.image;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoaded,
      builder: (_, loaded, __) {
        if (loaded) {
          return _paintImage();
        } else {
          return Container(
            height: widget.height ?? double.maxFinite,
            width: widget.width ?? double.maxFinite,
            child: Center(
              child: widget.placeHolder ?? const CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  ///paints image on given constrains for drawing if image is not null.
  Widget _paintImage() {
    return Scaffold(
      appBar: _buildControls(),
      body: Stack(
        children: [
          RepaintBoundary(
            key: _globalKey,
            child: ColorFiltered(
              colorFilter: widget.filter!,
              child: Container(
                  height: widget.height ?? double.maxFinite,
                  width: widget.width ?? double.maxFinite,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    alignment: FractionalOffset.center,
                    child: ClipRect(
                      child: ValueListenableBuilder<Controller>(
                        valueListenable: _controller,
                        builder: (_, controller, __) {
                          return ImagePainterTransformer(
                            maxScale: 2.4,
                            minScale: 1,
                            panEnabled: controller.mode == PaintMode.none,
                            scaleEnabled: widget.isScalable!,
                            onInteractionUpdate: (details) =>
                                _scaleUpdateGesture(details, controller),
                            onInteractionEnd: (details) =>
                                _scaleEndGesture(details, controller),
                            child: CustomPaint(
                              size: Size(_image!.width.toDouble(),
                                  _image!.height.toDouble()),
                              willChange: true,
                              isComplex: true,
                              painter: DrawImage(
                                image: _image,
                                points: _points,
                                fontSize: fontSize,
                                paintHistory: _paintHistory,
                                isDragging: _inDrag,
                                fontColor: fontColor,
                                update: UpdatePoints(
                                    start: _start,
                                    end: _end,
                                    painter: _painter,
                                    mode: controller.mode),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )),
            ),
          ),
          Positioned(
            bottom: 5,
            right: 25,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                onPressed: () {
                  convertImage();
                },
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                child: Icon(
                  Icons.check,
                  size: 24.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  convertImage() async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    //create file
    String dir = (await getApplicationDocumentsDirectory()).path;
    String fullPath = '$dir/${DateTime.now().millisecond}.png';
    capturedFile = File(fullPath);
    await capturedFile!.writeAsBytes(pngBytes);
    widget.onDone!.call(capturedFile!.path);
    print("path is " + capturedFile!.path.toString());
  }

  ///Fires while user is interacting with the screen to record painting.
  void _scaleUpdateGesture(ScaleUpdateDetails onUpdate, Controller ctrl) {
    setState(
      () {
        _inDrag = true;
        _start ??= onUpdate.focalPoint;
        _end = onUpdate.focalPoint;
        if (ctrl.mode == PaintMode.freeStyle) _points.add(_end);
        if (ctrl.mode == PaintMode.text &&
            _paintHistory
                .where((element) => element.mode == PaintMode.text)
                .isNotEmpty) {
          _paintHistory
              .lastWhere((element) => element.mode == PaintMode.text)
              .offset = [_end];
        }
      },
    );
  }

  ///Fires when user stops interacting with the screen.
  void _scaleEndGesture(ScaleEndDetails onEnd, Controller controller) {
    setState(() {
      _inDrag = false;
      if (_start != null &&
          _end != null &&
          (controller.mode == PaintMode.freeStyle)) {
        _points.add(null);
        _addFreeStylePoints();
        _points.clear();
      } else if (_start != null &&
          _end != null &&
          controller.mode != PaintMode.text) {
        _addEndPoints();
      }
      _start = null;
      _end = null;
    });
  }

  void _addEndPoints() => _addPaintHistory(
        PaintInfo(
          offset: <Offset?>[_start, _end],
          painter: _painter,
          mode: _controller.value.mode,
        ),
      );

  void _addFreeStylePoints() => _addPaintHistory(
        PaintInfo(
          offset: <Offset?>[..._points],
          painter: _painter,
          mode: PaintMode.freeStyle,
        ),
      );

  ///Provides [ui.Image] of the recorded canvas to perform action.
  Future<ui.Image> _renderImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final painter = DrawImage(
        image: _image,
        paintHistory: _paintHistory,
        fontSize: fontSize,
        fontColor: fontColor);
    final size = Size(_image!.width.toDouble(), _image!.height.toDouble());
    painter.paint(canvas, size);
    return recorder
        .endRecording()
        .toImage(size.width.floor(), size.height.floor());
  }

  PopupMenuItem _showRangeSlider() {
    return PopupMenuItem(
      enabled: false,
      child: SizedBox(
        width: double.maxFinite,
        child: ValueListenableBuilder<Controller>(
          valueListenable: _controller,
          builder: (_, ctrl, __) {
            return RangedSlider(
              value: ctrl.strokeWidth,
              onChanged: (value) {
                _controller.value = ctrl.copyWith(strokeWidth: value);
                if (widget.onStrokeWidthChanged != null) {
                  widget.onStrokeWidthChanged!(value);
                }
              },
            );
          },
        ),
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
                  if (widget.onFontSizeChanged != null) {
                    widget.onFontSizeChanged!(value);
                  }
                  fontSize = value;
                  setState(() {});
                });
          },
        ),
      ),
    );
  }

  ///Generates [Uint8List] of the [ui.Image] generated by the [renderImage()] method.
  ///Can be converted to image file by writing as bytes.
  Future<Uint8List?> exportImage() async {
    late ui.Image _convertedImage;
    if (widget.isSignature) {
      final _boundary = _repaintKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      _convertedImage = await _boundary.toImage(pixelRatio: 3);
    } else if (widget.byteArray != null && _paintHistory.isEmpty) {
      return widget.byteArray;
    } else {
      _convertedImage = await _renderImage();
    }
    final byteData =
        await _convertedImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  void _addPaintHistory(PaintInfo info) {
    if (info.mode != PaintMode.none) {
      _paintHistory.add(info);
    }
  }

  colorPicker(controller) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Pick a color!'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: Color(controller.color.value),
                onColorChanged: (color) {
                  _controller.value = controller.copyWith(color: color);
                  if (widget.onColorChanged != null) {
                    widget.onColorChanged!(color);
                  }
                  fontColor = color;
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

  void _openTextDialog() {
    _controller.value = _controller.value.copyWith(mode: PaintMode.text);
    double fontSize = 18;

    TextDialog.show(context, _textController, fontSize, _controller.value.color,
        textDelegate, onFinished: (c) {
      if (_textController.text != '') {
        setState(() {
          _addPaintHistory(
            PaintInfo(
                mode: PaintMode.text,
                text: _textController.text,
                painter: _painter,
                offset: []),
          );
        });
        _textController.clear();
      }
      Navigator.pop(context);
    });
  }

  PreferredSize _buildControls() {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: Container(
        padding: const EdgeInsets.all(4),
        color: Colors.black,
        child: Row(
          children: [
            IconButton(
              color: Colors.white,
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Spacer(),
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
            PopupMenuButton(
              tooltip: textDelegate.changeBrushSize,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              icon: widget.brushIcon ?? Icon(Icons.brush, color: Colors.white),
              itemBuilder: (_) => [_showRangeSlider()],
            ),
            IconButton(
                icon: const Icon(
                  Icons.text_format,
                  color: Colors.white,
                ),
                onPressed: _openTextDialog),
            IconButton(
              icon: Icon(
                Icons.crop_rotate,
                color: Colors.white,
              ),
              onPressed: () {
                _cropImage();
              },
            ),
            IconButton(
              tooltip: textDelegate.clearAllProgress,
              icon:
                  widget.clearAllIcon ?? Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                setState(_paintHistory.clear);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future _cropImage() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: widget.file!.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Crop',
              toolbarColor: Colors.red,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Crop',
          )
        ]);
    if (croppedFile != null) {
      widget.file = File(croppedFile.path);
      _resolveAndConvertImage();
      setState(() {});
    }
  }
}

///Gives access to manipulate the essential components like [strokeWidth], [Color] and [PaintMode].
@immutable
class Controller {
  ///Tracks [strokeWidth] of the [Paint] method.
  final double strokeWidth;
  final double fontSize;

  ///Tracks [Color] of the [Paint] method.
  final Color color;

  ///Tracks [PaintingStyle] of the [Paint] method.
  final PaintingStyle paintStyle;

  ///Tracks [PaintMode] of the current [Paint] method.
  final PaintMode mode;

  ///Any text.
  final String text;

  ///Constructor of the [Controller] class.
  const Controller(
      {this.strokeWidth = 4.0,
      this.color = Colors.red,
      this.fontSize = 52.0,
      this.mode = PaintMode.line,
      this.paintStyle = PaintingStyle.stroke,
      this.text = ""});

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Controller &&
        o.strokeWidth == strokeWidth &&
        o.color == color &&
        o.paintStyle == paintStyle &&
        o.mode == mode &&
        o.fontSize == fontSize &&
        o.text == text;
  }

  @override
  int get hashCode {
    return strokeWidth.hashCode ^
        color.hashCode ^
        paintStyle.hashCode ^
        mode.hashCode ^
        fontSize.hashCode ^
        text.hashCode;
  }

  ///copyWith Method to access immutable controller.
  Controller copyWith(
      {double? strokeWidth,
      double? fontSize,
      Color? color,
      PaintMode? mode,
      PaintingStyle? paintingStyle,
      String? text}) {
    return Controller(
        strokeWidth: strokeWidth ?? this.strokeWidth,
        color: color ?? this.color,
        mode: mode ?? this.mode,
        fontSize: fontSize ?? this.fontSize,
        paintStyle: paintingStyle ?? paintStyle,
        text: text ?? this.text);
  }
}

class TextDelegate {
  final String noneZoom = "None / Zoom";
  final String line = "Line";
  final String rectangle = "Rectangle";
  final String drawing = "Drawing";
  final String circle = "Circle";
  final String arrow = "Arrow";
  final String dashLine = "Dash line";
  final String text = "Text";
  final String changeMode = "Change Mode";
  final String changeColor = "Change Color";
  final String changeBrushSize = "Change Brush Size";
  final String undo = "Undo";
  final String done = "Done";
  final String clearAllProgress = "Clear All Progress";
}

class GradientCircularProgressIndicator extends StatelessWidget {
  final double? strokeWidth;
  final bool? strokeRound;
  final double? value;
  final Color? backgroundColor;
  final List<Color>? gradientColors;
  final List<double>? gradientStops;
  final double? radius;

  /// Constructor require progress [radius] & gradient color range [gradientColors]
  /// , option includes: circle width [strokeWidth], round support [strokeRound]
  /// , progress background [backgroundColor].
  ///
  /// set progress with [value], 0.0 to 1.0.
  GradientCircularProgressIndicator({
    this.strokeWidth = 10.0,
    this.strokeRound = false,
    required this.radius,
    required this.gradientColors,
    this.gradientStops,
    this.backgroundColor = Colors.transparent,
    this.value,
  });

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
  }

  @override
  Widget build(BuildContext context) {
    var _colors = gradientColors;
    if (_colors == null) {
      Color color = Theme.of(context).primaryColor;
      _colors = [color, color];
    }

    return Transform.rotate(
      angle: -pi / 2,
      child: CustomPaint(
        size: Size.fromRadius(radius!),
        painter: _GradientCircularProgressPainter(
            strokeWidth: strokeWidth!,
            strokeRound: strokeRound!,
            backgroundColor: backgroundColor!,
            gradientColors: _colors,
            value: value!,
            gradientStops: gradientStops,
            radius: radius!),
      ),
    );
  }
}

class _GradientCircularProgressPainter extends CustomPainter {
  _GradientCircularProgressPainter({
    this.strokeWidth,
    this.strokeRound,
    this.value,
    this.backgroundColor = Colors.transparent,
    this.gradientColors,
    this.gradientStops,
    this.radius,
  });

  final double? strokeWidth;
  final bool? strokeRound;
  final double? value;
  final Color? backgroundColor;
  final List<Color>? gradientColors;
  final double? radius;

  List<double>? gradientStops;
  double? total = 2 * pi;

  @override
  void paint(Canvas canvas, Size size) {
    if (radius != null) {
      size = Size.fromRadius(radius!);
    }

    double _value = (value ?? .0);
    _value = _value.clamp(.0, 1.0) * total!;
    double _start = .0;

    double _offset = strokeWidth! / 2;
    Rect rect = Offset(_offset, _offset) &
        Size(size.width - strokeWidth!, size.height - strokeWidth!);

    var paint = Paint()
      ..strokeWidth = strokeWidth!
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    if (backgroundColor != Colors.transparent) {
      paint.color = backgroundColor!;
      canvas.drawArc(rect, _start, total!, false, paint);
    }

    if (_value > 0) {
      paint.shader = SweepGradient(
              colors: gradientColors!,
              startAngle: 0.0,
              endAngle: _value,
              stops: gradientStops)
          .createShader(rect);

      canvas.drawArc(rect, _start, _value, false, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
