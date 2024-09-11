// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Player extends StatefulWidget {
  String? video;
  Player(this.video);

  @override
  State<Player> createState() => _VideoPlayersState();
}

late VideoPlayerController _controller;

class _VideoPlayersState extends State<Player> {
  @override
  void initState() {
    _controller = VideoPlayerController.file(File(widget.video!));

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();

    // BetterPlayerConfiguration betterPlayerConfiguration =
    //     BetterPlayerConfiguration(
    //   aspectRatio: 0.5,
    //   fit: BoxFit.fill,
    //   autoPlay: true,
    //   looping: true,
    //   subtitlesConfiguration: //a == null?BetterPlayerSubtitlesConfiguration():
    //       BetterPlayerSubtitlesConfiguration(fontColor: Colors.transparent),
    //   controlsConfiguration: BetterPlayerControlsConfiguration(
    //       iconsColor: Colors.transparent,
    //       textColor: Colors.transparent,
    //       progressBarPlayedColor: Colors.transparent,
    //       progressBarBackgroundColor: Colors.transparent,
    //       progressBarBufferedColor: Colors.transparent,
    //       progressBarHandleColor: Colors.transparent),
    //   expandToFill: true,
    //   deviceOrientationsAfterFullScreen: [
    //     DeviceOrientation.portraitDown,
    //     DeviceOrientation.portraitUp
    //   ],
    // );
    // _betterPlayerDataSource = BetterPlayerDataSource(
    //   BetterPlayerDataSourceType.file,
    //   widget.video!,
    // );
    // _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    // _betterPlayerController.setupDataSource(_betterPlayerDataSource);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: AspectRatio(
        aspectRatio: 0.5,
        child: VideoPlayer(_controller),
      ),
    );
  }
}
