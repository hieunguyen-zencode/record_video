import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:record_play_video/home_page.dart';
import 'package:record_play_video/play_video_and_record.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  List<CameraDescription> cameras = await availableCameras();
  runApp(App(
    cameras: cameras,
  ));
}

class App extends StatelessWidget {
  final List<CameraDescription> cameras;

  const App({Key? key, required this.cameras}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Record and play video',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PlayVideoAndRecord(
        title: 'Record',
        cameras: cameras,
      ),
    );
  }
}
