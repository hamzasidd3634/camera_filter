import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

// ignore: must_be_immutable
class EditImageScreen extends StatelessWidget {
  dynamic id;
  String? resource;
  ColorFilter? filter;
  Function(dynamic)? onDone;

  EditImageScreen({Key? key, this.id, this.resource, this.filter, this.onDone})
      : super(key: key);
  RxBool emojiShowing = false.obs;
  RxBool dragText = false.obs;
  RxBool update = false.obs;
  RxBool textFieldBool = false.obs;
  RxBool deleteButton = false.obs;
  Offset offset = Offset.zero;
  RxInt colorValue = 0xff443a49.obs;
  String text = '';
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController emojisEditingController = TextEditingController();
  File? capturedFile;
  final GlobalKey _globalKey = GlobalKey();

  _onEmojiSelected(Emoji emoji) {
    emojisEditingController
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: emojisEditingController.text.length));
  }

  _onBackspacePressed() {
    emojisEditingController
      ..text = emojisEditingController.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: emojisEditingController.text.length));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          color: Colors.white,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
        backgroundColor: Colors.black,
        elevation: 0.0,
        actions: <Widget>[
          Obx(
            () => deleteButton.value == false
                ? Container()
                : IconButton(
                    icon: Icon(
                      Icons.delete_forever,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      text = '';
                      deleteButton.value = false;
                      textFieldBool.value = false;
                      emojisEditingController.clear();
                      _textEditingController.clear();
                      dragText(!dragText.value);
                    },
                  ),
          ),
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
            icon: Icon(
              Icons.insert_emoticon,
              color: Colors.white,
            ),
            onPressed: () {
              emojiShowing(!emojiShowing.value);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.text_fields,
              color: Colors.white,
            ),
            onPressed: () {
              textFieldBool.value = true;
              deleteButton.value = true;
            },
          ),
          Obx(() => deleteButton.value == false
              ? Container()
              : IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (text != '') {
                      colorPicker();
                    }
                  },
                )),
        ],
      ),
      body: Obx(() {
        File file = File(resource!);
        Uint8List fileBytes = file.readAsBytesSync();
        ImageProvider image = MemoryImage(fileBytes);
        if (update.isFalse) {
          return bodyWidget(context, image);
        }
        return bodyWidget(context, image);
      }),
    );
  }

  Widget bodyWidget(BuildContext context, ImageProvider<Object> image) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              RepaintBoundary(
                key: _globalKey,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ColorFiltered(
                        colorFilter: filter!,
                        child: Image(
                          image: image,
                        ),
                      ),
                    ),
                    Obx(() {
                      if (dragText.isFalse) {
                        return positionedText();
                      } else {
                        return positionedText();
                      }
                    }),
                  ],
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
              Obx(() {
                if (textFieldBool.isFalse) {
                  return Container();
                } else {
                  return textField(context);
                }
              }),
              Obx(() {
                return Visibility(
                  visible: emojiShowing.value,
                  child: Column(
                    children: [
                      Expanded(child: Container()),
                      SizedBox(
                          height: 66.0,
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: TextFormField(
                                      controller: emojisEditingController,
                                      readOnly: true,
                                      style: const TextStyle(
                                          fontSize: 20.0,
                                          color: Colors.black87),
                                      decoration: InputDecoration(
                                        hintText: 'Emojis',
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding: const EdgeInsets.only(
                                            left: 16.0,
                                            bottom: 8.0,
                                            top: 8.0,
                                            right: 16.0),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                        ),
                                      )),
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: IconButton(
                                    onPressed: () {
                                      if (emojisEditingController
                                          .text.isNotEmpty) {
                                        emojiShowing.value = false;
                                        text += emojisEditingController.text;
                                        deleteButton.value = true;
                                        // textFieldBool.value = true;
                                        dragText(!dragText.value);
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.send,
                                      color: Colors.white,
                                    )),
                              )
                            ],
                          )),
                      Offstage(
                        offstage: !emojiShowing.value,
                        child: SizedBox(
                          height: 250,
                          child: EmojiPicker(
                              onEmojiSelected:
                                  (Category category, Emoji emoji) {
                                _onEmojiSelected(emoji);
                              },
                              onBackspacePressed: _onBackspacePressed,
                              config: Config(
                                  columns: 7,
                                  // Issue: https://github.com/flutter/flutter/issues/28894
                                  emojiSizeMax:
                                      32 * (Platform.isIOS ? 1.30 : 1.0),
                                  verticalSpacing: 0,
                                  horizontalSpacing: 0,
                                  initCategory: Category.RECENT,
                                  bgColor: const Color(0xFFF2F2F2),
                                  indicatorColor: Colors.blue,
                                  iconColor: Colors.grey,
                                  iconColorSelected: Colors.blue,
                                  progressIndicatorColor: Colors.blue,
                                  backspaceColor: Colors.blue,
                                  skinToneDialogBgColor: Colors.white,
                                  skinToneIndicatorColor: Colors.grey,
                                  enableSkinTones: true,
                                  showRecentsTab: true,
                                  recentsLimit: 28,
                                  noRecentsText: 'No Recents',
                                  noRecentsStyle: const TextStyle(
                                      fontSize: 20, color: Colors.black26),
                                  tabIndicatorAnimDuration: kTabScrollDuration,
                                  categoryIcons: const CategoryIcons(),
                                  buttonMode: ButtonMode.MATERIAL)),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          )),
    );
  }

  void changeColor(Color color) {
    colorValue.value = color.value;
  }

  colorPicker() {
    return Get.dialog(AlertDialog(
      title: const Text('Pick a color!'),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: Color(colorValue.value),
          onColorChanged: changeColor,
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('Ok'),
          onPressed: () {
            Get.back();
          },
        ),
      ],
    ));
  }

  Widget positionedText() {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: GestureDetector(
          onPanUpdate: (details) {
            offset = Offset(
                offset.dx + details.delta.dx, offset.dy + details.delta.dy);

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
                        fontSize: 28.0,
                        color: Color(colorValue.value)))),
              ),
            ),
          )),
    );
  }

  Widget textField(context) {
    return Center(
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
          Material(
            color: Colors.transparent,
            child: IconButton(
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
                )),
          )
        ],
      ),
    );
    //   Center(
    //   child: SizedBox(
    //     width: MediaQuery.of(context).size.width / 1.2,
    //     child: Container(
    //       decoration: BoxDecoration(
    //         border: Border(
    //           bottom: BorderSide(width: 0, color: Colors.black38),
    //         ),
    //       ),
    //       child: TextFormField(
    //         cursorColor: Colors.white,
    //         autofocus: true,
    //         controller: _textEditingController,
    //         style: TextStyle(color: Colors.white),
    //         onFieldSubmitted: (v) {
    //           text = v;
    //           textFieldBool.value = false;
    //           dragText(!dragText.value);
    //         },
    //         decoration: InputDecoration(
    //           border: InputBorder.none,
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }

  Future _cropImage() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: resource!,
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
      resource = croppedFile.path;
      update(!update.value);
    }
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
    onDone!.call(capturedFile!.path);
    print("path is " + capturedFile!.path.toString());
  }
}
