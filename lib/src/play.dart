// ignore_for_file: must_be_immutable

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Player extends StatefulWidget {
  String? video;
  Player(this.video);

  @override
  State<Player> createState() => _VideoPlayersState();
}

late BetterPlayerController _betterPlayerController;
late BetterPlayerDataSource _betterPlayerDataSource;

class _VideoPlayersState extends State<Player> {
  @override
  void initState() {
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
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: AspectRatio(
        aspectRatio: 0.5,
        child: BetterPlayer(controller: _betterPlayerController),
      ),
    );
  }
}
