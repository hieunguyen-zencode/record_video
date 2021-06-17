import 'package:camera/camera.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:record_play_video/video_player_widget.dart';
import 'package:record_play_video/video_view_page.dart';
import 'package:video_player/video_player.dart';

class PlayVideoAndRecord extends StatefulWidget {
  PlayVideoAndRecord({Key? key, required this.title, required this.cameras})
      : super(key: key);

  final List<CameraDescription> cameras;

  final String title;

  @override
  _PlayVideoAndRecordState createState() => _PlayVideoAndRecordState();
}

class _PlayVideoAndRecordState extends State<PlayVideoAndRecord>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late VideoPlayerController _videoPlayerController;
  late CameraController _cameraController;
  late ChewieController _chewieController;
  late Future<void> cameraValue;
  bool? isRecording;
  XFile? videoFile;

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    _videoPlayerController = VideoPlayerController.network(
        "https://assets.mixkit.co/videos/preview/mixkit-a-girl-blowing-a-bubble-gum-at-an-amusement-park-1226-large.mp4");
    isRecording = false;
    _cameraController = CameraController(
      widget.cameras[1],
      ResolutionPreset.high,
      enableAudio: true,
    );
    cameraValue = _cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    print("[Thang] : aaaaaaaa");
    onNewChewie(_videoPlayerController);

    super.didChangeDependencies();
  }

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> startVideoRecording() async {
    if (!_cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (_cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      await _cameraController.startVideoRecording();
    } on CameraException catch (e) {
      print(e);
      return;
    }
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((_) {
      _videoPlayerController.play();
      if (mounted) setState(() {});
    });
  }

  Future<XFile?> stopVideoRecording() async {
    if (!_cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return _cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      print(e);
      return null;
    }
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((file) {
      _videoPlayerController.pause();
      if (mounted) setState(() {});
      if (file != null) {
        showInSnackBar('Video recorded to ${file.path}');
        videoFile = file;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoViewPage(path: videoFile!.path),
          ),
        );
      }
    });
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    await _cameraController.dispose();
    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: true,
    );

    // If the controller is updated then update the UI.
    _cameraController.addListener(() {
      if (mounted) setState(() {});
      if (_cameraController.value.hasError) {
        showInSnackBar(
            'Camera error ${_cameraController.value.errorDescription}');
      }
    });

    try {
      await _cameraController.initialize();
    } on CameraException catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onNewChewie(VideoPlayerController _videoPlayerController) async {
    _chewieController = ChewieController(
      videoPlayerController: VideoPlayerController.network(
          "https://assets.mixkit.co/videos/preview/mixkit-a-girl-blowing-a-bubble-gum-at-an-amusement-park-1226-large.mp4"),
    );

    try {
      await _videoPlayerController.seekTo(Duration.zero);
    } on CameraException catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (!_cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.paused) {
      print("[Thang]: paused");
    }

    if (state == AppLifecycleState.inactive) {
      print("[Thang]: inactive");

      _videoPlayerController.dispose();
      _chewieController.dispose();
      _cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      print("[Thang]: resumed");
      onNewCameraSelected(_cameraController.description);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _videoPlayerController.dispose();
    _chewieController.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            Container(
              height: 250,
              child: FutureBuilder(
                future: cameraValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return VideoPlayerWidget(
                        videoPlayerController: _videoPlayerController);
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                color: Colors.black.withOpacity(0.5),
                child: IconButton(
                  onPressed: _cameraController.value.isInitialized &&
                          !_cameraController.value.isRecordingVideo
                      ? onVideoRecordButtonPressed
                      : onStopButtonPressed,
                  icon: Icon(
                    Icons.panorama_fish_eye,
                  ),
                  iconSize: 78,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
