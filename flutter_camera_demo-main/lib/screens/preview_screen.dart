import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_camera_demo/screens/camera_screen.dart';
import 'package:flutter_camera_demo/screens/captures_screen.dart';
import 'package:tflite/tflite.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

class PreviewScreen extends StatefulWidget {
  final File imageFile;
  final String recentImagePath;
  final List<File> fileList;

  const PreviewScreen({
    required this.imageFile,
    required this.recentImagePath,
    required this.fileList,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool _canShowButton = true;
  String bankonte = '';
  final assetsAudioPlayer = AssetsAudioPlayer();

  void hideWidget() {
    setState(() {
      _canShowButton = !_canShowButton;
    });
  }

  @override
  void initState() {
    super.initState();
    loadTfliteModel();
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadTfliteModel() async {
    String? res;
    res = await Tflite.loadModel(
        model: "assets/model1.tflite", labels: "assets/labels.txt");
    //model: "assets/OD Model.tflite");
    print(res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Go to all captures button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => CapturesScreen(
                      imageFileList: widget.fileList,
                    ),
                  ),
                );
              },
              child: Text('Go to all captures'),
              style: TextButton.styleFrom(
                primary: Colors.black,
                backgroundColor: Colors.white,
              ),
            ),
          ),

          Expanded(
            child: Image.file(widget.imageFile),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: !_canShowButton
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceEvenly,
              children: [
                //Check button
                !_canShowButton
                    ? const SizedBox.shrink()
                    : InkWell(
                        onTap: () async {
                          hideWidget();

                          var recognitions = await Tflite.runModelOnImage(
                              path: widget.recentImagePath, // required
                              imageMean: 127.5,
                              imageStd: 127.5,
                              numResults: 6,
                              threshold: 0.9, // defaults to 0.1
                              asynch: true // defaults to true
                              );

                          print(recognitions.toString());
                          print(recognitions![0]['label']
                              .toString()
                              .split(' ')[1]);

                          String banknote =
                              recognitions[0]['label'].toString().split(' ')[1];

                          //print()

                          //bankonte = recognitions.toString();

                          print('assets/audio/$banknote.mp3');
                          assetsAudioPlayer.open(
                            Audio("assets/audio/$banknote.mp3"),
                          );

                          AssetsAudioPlayer.newPlayer().open(
                            Audio("assets/audio/10.mp3"),
                          );

                          await Tflite.close();
                        },
                        child: Stack(alignment: Alignment.center, children: [
                          Icon(
                            Icons.circle,
                            color: Colors.white,
                            size: 80,
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.black,
                          ),
                        ]),
                      ),

                InkWell(
                  onTap: () {
                    widget.imageFile.delete();

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CameraScreen(),
                      ),
                    );
                  },
                  child: Stack(alignment: Alignment.center, children: [
                    Icon(
                      Icons.circle,
                      color: Colors.white,
                      size: 80,
                    ),
                    Icon(
                      !_canShowButton ? Icons.home : Icons.delete,
                      color: Colors.black,
                    ),
                  ]),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
