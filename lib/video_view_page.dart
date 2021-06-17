import 'dart:io';

import 'package:flutter/material.dart';
import 'package:record_play_video/video_player_widget.dart';
import 'package:video_player/video_player.dart';

class VideoViewPage extends StatefulWidget {
  final String path;
  const VideoViewPage({Key? key, required this.path}) : super(key: key);

  @override
  _VideoViewPageState createState() => _VideoViewPageState();
}

class _VideoViewPageState extends State<VideoViewPage> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    _videoPlayerController = VideoPlayerController.file(File(widget.path));
    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Review"),
      ),
      body: VideoPlayerWidget(
        videoPlayerController: _videoPlayerController,
      ),
    );
  }
}
