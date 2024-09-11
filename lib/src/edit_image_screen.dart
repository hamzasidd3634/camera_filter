import 'dart:io';

import 'package:camera_filters/src/draw_image.dart';
import 'package:camera_filters/src/painter.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class EditImageScreen extends StatefulWidget {
  ///path of image
  String? path;

  /// color filter
  ColorFilter? filter;

  ///function return the edited image path
  Function(dynamic)? onDone;

  ///send button widget
  Widget? sendButtonWidget;

  bool applyFilters;

  EditImageScreen(
      {Key? key,
      this.path,
      this.filter,
      this.onDone,
      this.sendButtonWidget,
      this.applyFilters = true})
      : super(key: key);

  @override
  State<EditImageScreen> createState() => _EditImageScreenState();
}

class _EditImageScreenState extends State<EditImageScreen> {
  /// image key
  final _imageKey = GlobalKey<ImagePainterState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: ImagePainter.file(
          File(widget.path!),
          key: _imageKey,
          scalable: true,
          filter: widget.filter,
          applyFilters: widget.applyFilters,
          initialStrokeWidth: 2,
          onDone: widget.onDone,
          width: MediaQuery.of(context).size.width,
          initialColor:
              widget.applyFilters == false ? Colors.transparent : Colors.green,
          initialPaintMode: PaintMode.freeStyle,
        ),
      ),
    );
  }
}
