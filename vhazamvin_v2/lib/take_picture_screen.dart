//import 'dart:html';
// ignore_for_file: unused_import, unnecessary_import

import 'dart:convert';
//import 'dart:html';
//import 'dart:io';

//import 'package:image_picker/image_picker.dart';
import 'package:vhazamvin_v2/home.dart';
import 'package:vhazamvin_v2/login.dart';
import 'package:vhazamvin_v2/wine_page.dart';
import 'package:google_ml_vision/google_ml_vision.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
//import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:video_player/video_player.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({Key? key, required this.camera}) : super(key: key);

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    //To display ythe current output from the Camera,
    // create a CameraController
    _controller = CameraController(
        widget
            .camera, // Get a specific camera from the list of available cameras
        ResolutionPreset.max // Define the resolution to use
        );

    _initializeControllerFuture = _controller
        .initialize(); // Next, initialize the controller. This return a Future.
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            // If the picture was taken, display it on a new screen.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  imagePath: image.path,
                ),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => DisplayPictureScreenState();
}

class DisplayPictureScreenState extends State<DisplayPictureScreen> {
  Future<List<String>> extractText(String imagePath) async {
    List<String> _result = [];
    final GoogleVisionImage visionImage =
        GoogleVisionImage.fromFilePath(imagePath);
    final TextRecognizer textRecognizer =
        GoogleVision.instance.textRecognizer();
    final VisionText visionText =
        await textRecognizer.processImage(visionImage);
    String text = visionText.text ?? "";
    for (TextBlock block in visionText.blocks) {
      final Rect? boundingBox = block.boundingBox;
      final List<Offset> cornerPoints = block.cornerPoints;
      final String text = block.text ?? "";
      final List<RecognizedLanguage> languages = block.recognizedLanguages;

      for (TextLine line in block.lines) {
        _result.add(line.text ?? "");
        //print(line.text);
        for (TextElement element in line.elements) {
          // Same getters as TextBlock
        }
      }
    }
    return _result;
  }

  Future<ApiResponse> getWine(String request) async {
    ApiResponse _apiResponse = new ApiResponse();
    var url = Uri.parse('http://192.168.19.47:3211/api/getwine');
    var response = await http.post(url, body: {'scan': request});
    switch (response.statusCode) {
      case 200:
        var result = json.decode(response.body);
        _apiResponse.Data = result;
        break;
      case 401:
        _apiResponse.ApiError = ApiError.fromJson(json.decode(response.body));
        break;
      default:
        _apiResponse.ApiError = ApiError.fromJson(json.decode(response.body));
        break;
    }
    return _apiResponse;
  }

  Future<ApiResponse> tryToGetWine(String imagePath) async {
    List<String> result = await extractText(widget.imagePath);
    var apiResult = await getWine(result.toString());
    return apiResult;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Display the Picture')),
        // The image is stored as a file on the device. Use the `Image.file`
        // constructor with the given path to display the image.
        body: //Image.file(File(widget.imagePath)),
            Container(
          child: FutureBuilder<ApiResponse>(
              //future: getWine("WineName"), //pour le moment je triche ici
              //future: tryToGetWine(widget.imagePath),
              builder:
                  (BuildContext context, AsyncSnapshot<ApiResponse> snapshot) {
            List<Widget> children;
            if (snapshot.hasData) {
              if (snapshot.data!.Data != null) {
                return WinePage(request: snapshot.data!.Data);
              }
              return HomePage();
              /*
                  children = <Widget>[
                    Column(
                      children: <Widget>[
                        SizedBox(
                          height: 400.0,
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Text(snapshot.data![index]);
                            },
                          ),
                        ),
                      ],
                    )
                  ];*/
            } else if (snapshot.hasError) {
              children = <Widget>[
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('Error: ${snapshot.error}'),
                )
              ];
            } else {
              children = const <Widget>[
                SizedBox(
                  child: CircularProgressIndicator(),
                  width: 60,
                  height: 60,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Awaiting result...'),
                )
              ];
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: children,
              ),
            );
          }),
        ));
  }
}

/*
class TakePictureScreen extends StatefulWidget {
  TakePictureScreen({Key? key, required this.camera}) : super(key: key);
  final CameraDescription camera;

  @override
  _TakePictureScreenState createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("rest"),
      ),
      body: Center(child: Text("Image is not loaded")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: Icon(Icons.camera_alt),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
*/