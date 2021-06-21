import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
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
    _videoPlayerController
      ..initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
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
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(top: 30, left: 20),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                size: 32,
              ),
              color: Colors.white,
            ),
          ),
          Flexible(
            child: VideoPlayerWidget(
              videoPlayerController: _videoPlayerController,
            ),
          ),
          InkWell(
            onTap: () {
              uploadToAWS();
            },
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.upload,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Upload to Server",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
              height: 65,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  uploadToAWS() async {
    final dio = Dio();
    var tokenResponse = await dio.post(
      'https://testapi.moodie.ai/auth/login',
      data: {"email": "hoang.tran@zencode.guru", "password": "password"},
    );

    try {
      String fileName = basename(widget.path);

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          widget.path,
          filename: fileName,
        )
      });

      final response = await dio.post(
        "https://testapi.moodie.ai/file/uploadVideo",
        data: formData,
        options: Options(
          contentType: "video/mp4",
          headers: {
            "authorization": "Bearer ${tokenResponse.data['token']}",
          },
        ),
      );

      print(response);
    } catch (e) {
      print(e);
    }
  }
}
