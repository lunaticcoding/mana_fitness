import 'package:colosseum/controller/components/camera_wrapper.dart';
import 'package:colosseum/controller/components/local_file_webview.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'components/camera_wrapper.dart';

dynamic camera = CameraWrapper();

Future<void> main() async {
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft]);
  SystemChrome.setEnabledSystemUIOverlays([]);

  camera.initCamera();
  runApp(PushupController());
}

class PushupController extends StatefulWidget {
  PushupController({Key key}) : super(key: key);

  @override
  _PushupControllerState createState() => _PushupControllerState();
}

class _PushupControllerState extends State<PushupController> {
  FaceDetector faceDetector = FirebaseVision.instance.faceDetector();
  FlutterWebviewPlugin flutterWebviewPlugin = FlutterWebviewPlugin();

  String path = 'assets/pong/';
  String htmlFile = 'index.html';
  List<String> jsFiles = ['p5min.js', 'sketch.js'];

//  String filePath = 'assets/test.html';
  double range;

  @override
  void initState() {
    super.initState();
    range = 0.0;
    camera.initializeCamera(faceDetector.processImage, onFaceDetected);
  }

  void onFaceDetected(dynamic faces) {
    if (faces.length != 0) {
      double dist_in_pix =
          faces[0].boundingBox.right - faces[0].boundingBox.left;
      dist_in_pix = (dist_in_pix > 550) ? 550 : dist_in_pix;
      dist_in_pix = (dist_in_pix < 250) ? 250 : dist_in_pix;
      double range = 1.0 - (dist_in_pix - 250) / (550 - 250);
      flutterWebviewPlugin.evalJavascript('controller($range)');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LocalFileWebview(
        flutterWebviewPlugin: flutterWebviewPlugin,
        path: path,
        htmlFile: htmlFile,
        jsFiles: jsFiles,
      ),
    );
  }

  void dispose() {
    camera.dispose();
    faceDetector.close();
    super.dispose();
  }
}