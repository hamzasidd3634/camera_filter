import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VideoPlayer extends StatefulWidget {
  String? video;
  VideoPlayer(this.video);

  @override
  State<VideoPlayer> createState() => _VideoPlayersState();
}

late BetterPlayerController _betterPlayerController;
late BetterPlayerDataSource _betterPlayerDataSource;

class _VideoPlayersState extends State<VideoPlayer> {
  @override
  void initState() {
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      aspectRatio: 3 / 3,
      fit: BoxFit.fill,
      autoPlay: true,
      looping: false,
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
      height: double.infinity,
      width: MediaQuery.of(context).size.width,
      child: BetterPlayer(controller: _betterPlayerController),
    );
  }
}
