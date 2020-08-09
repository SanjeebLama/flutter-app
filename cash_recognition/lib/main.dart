import 'dart:async';
// import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

import 'package:tflite/tflite.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
      ),
    ),
  );
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

//variables for image output, image path and loading

  // bool _loading = false;
  List _outputs = List();
  String path;
  String _imagePath;

  @override
  void initState() {
    super.initState();

    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();

    //After importing libraries, it’s time to load your .tflite model in main.dart .
    //We will be using a bool variable _loading to show CircularProgressIndicator while the model is loading.
    // _loading = true;

    loadModel().then((value) {
      setState(() {
        // _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Take the Picture in a try / catch block. If anything goes wrong,
        // catch the error.
        try {
          // Ensure that the camera is initialized.
          await _initializeControllerFuture;

          // Construct the path where the image should be saved using the
          // pattern package.
          path = join(
            // Store the picture in the temp directory.
            // Find the temp directory using the `path_provider` plugin.
            (await getTemporaryDirectory()).path,
            '${DateTime.now()}.png',
          );
          _imagePath = path.toString();
          print(" !!!!!!! Image Path IMAGE PATH  : " + path.toString());

          // Attempt to take a picture and log where it's been saved.
          await _controller.takePicture(path);

          //Send image for classification

          // If the picture was taken, display it on a new screen.
          if (_imagePath != null) {
            sendImage();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return _buildSpeechBar();
                // => DisplayPictureScreen(imagePath: path),
              }),
            );
          } else {
            print('IMAGE PATH IS NULLLLLLLL');
          }
          // _buildSpeechBar(),
        } catch (e) {
          // If an error occurs, log the error to the console.
          print(e);
        }
      },
      child: Stack(
        children: <Widget>[
          Scaffold(
            // appBar: AppBar(title: Text('Take a picture')),
            // Wait until the controller is initialized before displaying the
            // camera preview. Use a FutureBuilder to display a loading spinner
            // until the controller has finished initializing.
            body: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If the Future is complete, display the preview.
                  return CameraPreview(_controller);
                } else {
                  // Otherwise, display a loading indicator.
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
            // floatingActionButton: FloatingActionButton(
            //   child: Icon(Icons.camera_alt),
            //   // Provide an onPressed callback.
            //   onPressed: () async {
            //     // Take the Picture in a try / catch block. If anything goes wrong,
            //     // catch the error.
            //     try {
            //       // Ensure that the camera is initialized.
            //       await _initializeControllerFuture;

            //       // Construct the path where the image should be saved using the
            //       // pattern package.
            //       final path = join(
            //         // Store the picture in the temp directory.
            //         // Find the temp directory using the `path_provider` plugin.
            //         (await getTemporaryDirectory()).path,
            //         '${DateTime.now()}.png',
            //       );

            //       print(
            //           "Image Path IMAGE PATH IMAGE PATH  : " + path.toString());

            //       // Attempt to take a picture and log where it's been saved.
            //       await _controller.takePicture(path);

            //       // If the picture was taken, display it on a new screen.
            //       //  SnackBar(content: 'Image')

            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) =>
            //               DisplayPictureScreen(imagePath: path),
            //         ),
            //       );
            //     } catch (e) {
            //       // If an error occurs, log the error to the console.
            //       print(e);
            //     }
            //   },
            // ),
          ),
          // _buildTopHeader(),
          _buildInfoBar(),
        ],
      ),
    );
  }

  Widget _buildInfoBar() {
    return Positioned(
      bottom: 0.0,
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Material(
              color: Colors.white,
              elevation: 14.0,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35.0),
                topRight: Radius.circular(35.0),
              ),
              shadowColor: Color(0x802196F3),
              child: _buildInitContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitContent() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 60.0,
        child: Column(
          children: <Widget>[
            _titleContainer(),
          ],
        ),
      ),
    );
  }

  Widget _titleContainer() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          Text(
            "Click to take Picture of Cash",
            style: TextStyle(fontSize: 20.0, color: Colors.cyan),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeechBar() {
    return Positioned(
      bottom: 0.0,
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Material(
              color: Colors.white,
              elevation: 14.0,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35.0),
                topRight: Radius.circular(35.0),
              ),
              shadowColor: Color(0x802196F3),
              child: _buildFinalContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalContent() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 70.0,
        child: Column(
          children: <Widget>[
            _buildImagePath(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePath() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          Text(
            "${_outputs[0]["label"]}",
            style: TextStyle(fontSize: 14.0, color: Colors.cyan),
          ),
        ],
      ),
    );
  }

  //Sending image for classifying
  sendImage() async {
    //ClassifyImage
    var output = await Tflite.runModelOnImage(
      path: _imagePath,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      // _loading = false;
      //Declare List _outputs in the class which will be used to show the classified classs name and confidence
      _outputs = output;
    });
  }

//Load the Tflite model
  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();

    //Dispose Tensorflow Lite
    Tflite.close();
    super.dispose();
  }
}

// // A widget that displays the picture taken by the user.
// class DisplayPictureScreen extends StatelessWidget {
//   final String imagePath;

//   const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Display the Picture')),
//       // The image is stored as a file on the device. Use the `Image.file`
//       // constructor with the given path to display the image.
//       body: Image.file(File(imagePath)),
//     );
//   }
// }
