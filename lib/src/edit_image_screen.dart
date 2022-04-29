import 'dart:io';

import 'package:camera_filters/src/draw_image.dart';
import 'package:camera_filters/src/painter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class EditImageScreen extends StatefulWidget {
  dynamic id;
  String? resource;
  ColorFilter? filter;
  Function(dynamic)? onDone;

  EditImageScreen({Key? key, this.id, this.resource, this.filter, this.onDone})
      : super(key: key);

  @override
  State<EditImageScreen> createState() => _EditImageScreenState();
}

class _EditImageScreenState extends State<EditImageScreen> {
  RxBool update = false.obs;
  final _imageKey = GlobalKey<ImagePainterState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: ImagePainter.file(
          File(widget.resource!),
          key: _imageKey,
          scalable: true,
          filter: widget.filter,
          initialStrokeWidth: 2,
          onDone: widget.onDone,
          width: MediaQuery.of(context).size.width,

          // textDelegate: DutchTextDelegate(),
          initialColor: Colors.green,
          initialPaintMode: PaintMode.freeStyle,
        ),
      ),
    );
  }
}
