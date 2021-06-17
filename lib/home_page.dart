import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:record_play_video/video_view_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title, required this.cameras})
      : super(key: key);

  final List<CameraDescription> cameras;
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late CameraController _cameraController;
  late Future<void> cameraValue;
  XFile? videoFile;

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);

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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (!_cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(_cameraController.description);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
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
            FutureBuilder(
              future: cameraValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_cameraController);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
            Positioned(
              right: 0,
              bottom: 0,
              left: 0,
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
