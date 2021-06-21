import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:record_play_video/play_video_and_record.dart';

class HomePage extends StatefulWidget with WidgetsBindingObserver {
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
      _cameraController.dispose();
    }
    if (state == AppLifecycleState.resumed) {
      print("[Thang]: resumed");
      onNewCameraSelected(_cameraController.description);
    }
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
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: OrientationBuilder(builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            return onLandcapeMode();
          }
          return onPortraitMode();
        }),
      ),
    );
  }

  Widget onPortraitMode() {
    return Stack(
      children: [
        Positioned.fill(
          child: FutureBuilder(
            future: cameraValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Column(
                  children: [
                    CameraPreview(_cameraController),
                  ],
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
        Positioned(
          bottom: -MediaQuery.of(context).size.width / 6,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.grey.withOpacity(0.5),
            child: Icon(
              Icons.person,
              size: MediaQuery.of(context).size.width,
              color: Colors.transparent.withOpacity(0.4),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                color: Colors.black,
                height: MediaQuery.of(context).size.height / 4,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.black,
                height: MediaQuery.of(context).size.height / 4,
                padding: EdgeInsets.only(top: 40),
                child: Column(
                  children: [
                    Text(
                      "Please move yourself into the target zone.",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      "And start recording when you are ready.",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    buttonRecord(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget onLandcapeMode() {
    return Stack(
      children: [
        FutureBuilder(
          future: cameraValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: CameraPreview(_cameraController),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            color: Colors.grey.withOpacity(0.5),
            child: Icon(
              Icons.person,
              size: 450,
              color: Colors.black.withOpacity(0.4),
            ),
          ),
        ),
        Positioned(
          top: 30,
          left: 5,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                SizedBox(height: 10),
                Text(
                  "Please move yourself into the target zone.",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  "And start recording when you are ready.",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          left: 0,
          child: Container(
            height: 40,
            width: double.infinity,
            color: Colors.black,
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          left: 0,
          child: buttonRecord(),
        ),
      ],
    );
  }

  Widget buttonRecord() {
    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayVideoAndRecord(
              cameras: widget.cameras,
            ),
          ),
        );
      },
      icon: Icon(
        Icons.panorama_fish_eye,
      ),
      iconSize: 56,
      color: Colors.white,
    );
  }
}
