import 'dart:io';

import 'package:blackcofferapp/components/customappbar.dart';
import 'package:blackcofferapp/pages/uploadvid.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocode/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent/android_intent.dart';
import '../main.dart';

class Recorder extends StatefulWidget {
  Recorder({Key? key}) : super(key: key);

  @override
  _RecorderState createState() => _RecorderState();
}

class _RecorderState extends State<Recorder> {
  late File vidoeFile;
  bool isPaused = false;
  bool isRecording = false;
  bool isRear = true;
  late GeoCode geoCode;
  String addressline = "";
  late CameraController controller;
  late Future<void> initializeController;
  CameraDescription camera = cameras[0];

  void initCameraController() {
    controller = CameraController(camera, ResolutionPreset.max);
    initializeController = controller.initialize();
  }

  @override
  void initState() {
    super.initState();
    geoCode = GeoCode();
    initCameraController();
  }

  void switchCameraToSelfie() {
    setState(() {
      camera = cameras[1];
      isRear = false;
    });
    initCameraController();
  }

  void switchCameraToRear() {
    setState(() {
      camera = cameras[0];
      isRear = true;
    });
    initCameraController();
  }

  void pauseVideoRecording() async {
    await controller.pauseVideoRecording().then((_) => {
          setState(() {
            isPaused = true;
            isRecording = false;
          }),
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Recording Paused")))
        });
  }

  void recordVideo() async {
    if (isPaused) {
      await controller.resumeVideoRecording().then((_) => {
            setState(() {
              isRecording = true;
              isPaused = false;
            }),
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("Recording Resumed")))
          });
    } else {
      await controller.startVideoRecording().then((_) => {
            setState(() {
              isRecording = true;
              isPaused = false;
            }),
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("Recording Started")))
          });
    }
  }

  void stopRecordingAndPost() async {
    await controller.stopVideoRecording().then((xfile) => {
          setState(() {
            isPaused = false;
            isRecording = false;
            vidoeFile = File(xfile.path);
          }),
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => Uploader(
                filetoupload: vidoeFile,
                location: addressline,
              ),
            ),
          )
        });
  }

  void openLocationSetting() async {
    final AndroidIntent intent = new AndroidIntent(
      action: 'android.settings.LOCATION_SOURCE_SETTINGS',
    );
    await intent.launch();
  }

  Future<void> _gpsDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
          title: Text("Turn on Location Services"),
          content: Text("For Presice location you need to turn on GPS service"),
          actions: <Widget>[
            CupertinoButton(
              child: Text(
                "Okay !",
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                openLocationSetting();
                Navigator.of(context).pop();
              },
            ),
            CupertinoButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Future<void> getLocation() async {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Getting User's Location")));
    await Permission.location.request().whenComplete(() => {_gpsDialog()});
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then(
      (value) async {
        Address address = await geoCode.reverseGeocoding(
            latitude: value.latitude, longitude: value.longitude);
        setState(() {
          addressline = address.region ?? "";
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Location Got Successfully")));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        CustomAppBar(
          title: "Recorder",
        ),
        Expanded(
          child: addressline.length == 0
              ? FutureBuilder(
                  future: initializeController,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Stack(
                        children: [
                          Container(
                            child: CameraPreview(controller),
                          ),
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: CupertinoButton.filled(
                                  child: Text("Start"),
                                  onPressed: () {
                                    getLocation();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                )
              : FutureBuilder(
                  future: initializeController,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Stack(
                        children: [
                          Container(
                            child: CameraPreview(controller),
                          ),
                          Positioned.fill(
                            top: 100.0,
                            right: 10.0,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () => {switchCameraToRear()},
                                child: FaIcon(
                                  FontAwesomeIcons.camera,
                                  size: 30.0,
                                  color: !isRear ? Colors.white : Colors.blue,
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            top: -100.0,
                            right: 10.0,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () => {switchCameraToSelfie()},
                                child: FaIcon(
                                  FontAwesomeIcons.portrait,
                                  size: 30.0,
                                  color: isRear ? Colors.white : Colors.blue,
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            bottom: 100.0,
                            right: 70,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: GestureDetector(
                                onTap: () => {pauseVideoRecording()},
                                child: FaIcon(
                                  FontAwesomeIcons.pauseCircle,
                                  size: 50.0,
                                  color: !isPaused ? Colors.white : Colors.red,
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            bottom: 100.0,
                            left: 70.0,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: GestureDetector(
                                onTap: () => {recordVideo()},
                                child: FaIcon(
                                  FontAwesomeIcons.playCircle,
                                  size: 50.0,
                                  color:
                                      !isRecording ? Colors.white : Colors.red,
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: CupertinoButton.filled(
                                  child: Text("Post"),
                                  onPressed: () {
                                    stopRecordingAndPost();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
        ),
        SizedBox(
          height: 10.0,
        ),
      ],
    ));

    //
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
