import 'dart:typed_data';
import 'package:blackcofferapp/home.dart';
import 'package:blackcofferapp/pages/uploadsuccess.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:blackcofferapp/components/customappbar.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Uploader extends StatefulWidget {
  final filetoupload, location;
  Uploader({required this.filetoupload, required this.location});

  @override
  _UploaderState createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  String videoTitle = "";
  String vidoeCategory = "";
  String? location;
  bool isImageReady = false;
  String uploadUrl = "";
  String? uid;
  String? username;
  Uint8List? bytes;

  Future<void> _getUID() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {
      uid = _prefs.getString("uid");
      username = _prefs.getString("username");
    });
  }

  void navigateToHome() {
    Navigator.push(context, CupertinoPageRoute(builder: (context) => Home()));
  }

  void navigateToSuccessPage() {
    Navigator.push(
        context, CupertinoPageRoute(builder: (context) => UploadSuccess()));
  }

  void getThumbnail() async {
    await VideoThumbnail.thumbnailData(
      video: this.widget.filetoupload.path,
      maxHeight: 600,
      quality: 30,
    ).then((value) => {
          setState(() {
            bytes = value;
            isImageReady = true;
          })
        });
  }

  void uploadTheVideo() async {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Uploading Video....")));

    Map<String, Object> newVideo = {};
    String filename = path.basename(this.widget.filetoupload.path);
    Reference storageReference =
        FirebaseStorage.instance.ref().child("/videos").child(filename);
    UploadTask storageUploadTask =
        storageReference.putFile(this.widget.filetoupload);
    await storageUploadTask.whenComplete(
      () async => {
        uploadUrl = await storageReference.getDownloadURL(),
      },
    );
    newVideo = {
      "uploadedby": uid ?? "",
      "username": username ?? "username",
      "category": vidoeCategory,
      "searchword": videoTitle.replaceAll(new RegExp("r\s+"), "").trim(),
      "url": uploadUrl,
      "thumbnail": bytes.toString(),
      "location": location ?? this.widget.location,
      "title": videoTitle,
      "likes": "0",
      "comments": [],
      "dislikes": "0",
      "views": "0",
      "uploaddate": DateTime.now().toString()
    };
    await FirebaseFirestore.instance.collection("videos").add(newVideo).then(
          (_) => {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Video Uploaded Successfully"))),
            navigateToSuccessPage()
          },
        );
  }

  @override
  void initState() {
    super.initState();
    getThumbnail();
    _getUID();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(
            label: "Home",
            icon: FaIcon(
              FontAwesomeIcons.video,
              color: Colors.black,
            ),
          ),
          BottomNavigationBarItem(
            label: "Add",
            icon: FaIcon(
              FontAwesomeIcons.plusCircle,
              color: Colors.black,
            ),
          ),
          BottomNavigationBarItem(
            label: "Library",
            icon: FaIcon(
              FontAwesomeIcons.photoVideo,
              color: Colors.black,
            ),
          ),
        ],
        onTap: (index) {
          navigateToHome();
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomAppBar(
              title: "Upload Video",
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: !isImageReady
                  ? Container(
                      child: Text("Loading"),
                    )
                  : Container(
                      child: Image.memory(
                        bytes!,
                        height: 250.0,
                      ),
                    ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: "Video title",
                ),
                onChanged: (String val) {
                  setState(() {
                    videoTitle = val;
                  });
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "Video Location",
                  ),
                  controller: TextEditingController(text: this.widget.location),
                  onChanged: (String val) {
                    setState(() {
                      location = val;
                    });
                  }),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "Video Category",
                  ),
                  onChanged: (String val) {
                    setState(() {
                      vidoeCategory = val;
                    });
                  }),
            ),
            SizedBox(
              height: 30.0,
            ),
            CupertinoButton.filled(
                child: Text("Post Video"),
                onPressed: () {
                  uploadTheVideo();
                }),
          ],
        ),
      ),
    );
  }
}
