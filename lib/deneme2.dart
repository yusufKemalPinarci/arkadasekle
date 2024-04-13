import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'firebase_service.dart';


class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late File _image;
  late List _results;

  @override
  void initState() {
    super.initState();
    _image = File('');
    _results = [];
    // loadModel();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image classification'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickAnImage,
        tooltip: 'Select Image',
        child: Icon(Icons.image),
      ),
      body: ListView(
          children: [Column(
            children: [
              if (_image != null)
                Container(margin: EdgeInsets.all(10), child: Image.file(_image))
              else
                Container(
                  margin: EdgeInsets.all(40),
                  child: Opacity(
                    opacity: 0.6,
                    child: Center(
                      child: Text('No Image Selected!'),
                    ),
                  ),
                ),
              SingleChildScrollView(
                child: Column(
                  children: _results != null
                      ? _results.map((result) {
                    return Card(
                      child: Container(
                        margin: EdgeInsets.all(10),
                        child: Text(
                          "${result["label"]} -  ${result["confidence"].toStringAsFixed(2)}",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList()
                      : [],
                ),
              ),
            ],
          ),]
      ),
    );
  }
/*
  Future loadModel() async {
    Tflite.close();
    String res;
    res = (await Tflite.loadModel(
      model: "assets/mobilenet_v1_1.0_224.tflite",
      labels: "assets/labels.txt",
    ))!;
    print(res);
  }*/

  Future pickAnImage() async {
    // pick image and...
    var image = await pickImage(ImageSource.camera);
    print(image);
    // Perform image classification on the selected image.
   // imageClassification(image as File);
  }
/*
  Future imageClassification(File image) async {
    // Run tensorflowlite image classification model on the image
    final List? results = await Tflite.detectObjectOnImage(
      path: image.path,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _results = results!;
      _image = image;
    });
  }*/
}