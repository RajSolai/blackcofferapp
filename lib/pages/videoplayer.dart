import 'package:blackcofferapp/components/customappbar.dart';
import 'package:blackcofferapp/home.dart';
import 'package:blackcofferapp/pages/usersvid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerView extends StatefulWidget {
  final views,
      videourl,
      likes,
      dislikes,
      daycount,
      comments,
      title,
      id,
      category,
      username,
      uid;
  const VideoPlayerView(
      {Key? key,
      required this.category,
      required this.title,
      required this.username,
      required this.id,
      required this.uid,
      required this.comments,
      required this.videourl,
      required this.views,
      required this.daycount,
      required this.likes,
      required this.dislikes});

  @override
  _VideoPlayerViewState createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  final String avatarUrl =
      "https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png";
  VideoPlayerController? _controller;
  bool isPlaying = false;
  int likeCount = 0;
  List comments = [];
  String commentText = "";
  int viewCount = 0;
  String? currentUsername;
  int dislikeCount = 0;

  Future<void> _getUID() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUsername = _prefs.getString("username");
    });
  }

  Future<void> postComment() async {
    Map newComment = {
      "msg": commentText,
      "username": currentUsername,
    };
    await FirebaseFirestore.instance
        .collection("videos")
        .doc(this.widget.id)
        .update({
      "comments": [...comments, newComment]
    }).then((_) => {
              setState(() {
                comments = [...comments, newComment];
              })
            });
  }

  void navigateToHome() {
    Navigator.push(context, CupertinoPageRoute(builder: (context) => Home()));
  }

  void shareVideo(String videoUrl) async {
    await Share.share('Check out this video $videoUrl',
        subject: 'Sharing Video from Blackcoffer App');
  }

  void openAllVideosPage(String uid) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => UserVid(
          uid: uid,
          user: this.widget.username,
        ),
      ),
    );
  }

  Future<void> updateViewCount() async {
    await FirebaseFirestore.instance
        .collection("videos")
        .where("url", isEqualTo: this.widget.videourl)
        .get()
        .then(
          (element) => {
            element.docs.forEach(
              (doc) async {
                await FirebaseFirestore.instance
                    .collection("videos")
                    .doc(doc.id)
                    .update({"views": (viewCount + 1).toString()});
                ++viewCount;
              },
            )
          },
        );
  }

  Future<void> updateLikeCount() async {
    await FirebaseFirestore.instance
        .collection("videos")
        .where("url", isEqualTo: this.widget.videourl)
        .get()
        .then(
          (element) => {
            element.docs.forEach(
              (doc) async {
                await FirebaseFirestore.instance
                    .collection("videos")
                    .doc(doc.id)
                    .update({"likes": (likeCount + 1).toString()});
                setState(() {
                  likeCount++;
                });
              },
            )
          },
        );
  }

  Future<void> updateDislikeCount() async {
    await FirebaseFirestore.instance
        .collection("videos")
        .where("url", isEqualTo: this.widget.videourl)
        .get()
        .then(
          (element) => {
            element.docs.forEach(
              (doc) async {
                await FirebaseFirestore.instance
                    .collection("videos")
                    .doc(doc.id)
                    .update({"dislikes": (dislikeCount + 1).toString()});
                setState(() {
                  dislikeCount++;
                });
              },
            )
          },
        );
  }

  @override
  void initState() {
    super.initState();
    likeCount = this.widget.likes;
    dislikeCount = this.widget.dislikes;
    viewCount = this.widget.views;
    comments = this.widget.comments;
    _getUID();
    _controller = VideoPlayerController.network(this.widget.videourl)
      ..initialize().then(
        (_) => {
          _controller!.play(),
          setState(() {
            isPlaying = true;
          }),
          updateViewCount()
        },
      );
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
              title: "Explore",
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      onTap: () {
                        navigateToHome();
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          hintText: "Search Videos"),
                      onChanged: (String val) {},
                    ),
                  ),
                  SizedBox(
                    width: 80.0,
                    child: CupertinoButton(
                      onPressed: () => {navigateToHome()},
                      child: Text(
                        "Filter",
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 300.0,
              child: isPlaying
                  ? VideoPlayer(_controller!)
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
            Container(
              child: Column(
                children: [
                  SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    this.widget.title,
                    style: TextStyle(fontSize: 30.0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CupertinoButton(
                          child: Row(
                            children: [
                              FaIcon(FontAwesomeIcons.thumbsUp),
                              SizedBox(
                                width: 5.0,
                              ),
                              Text("Like"),
                              SizedBox(
                                width: 5.0,
                              ),
                              Text(likeCount.toString()),
                            ],
                          ),
                          onPressed: () {
                            updateLikeCount();
                          }),
                      CupertinoButton(
                          child: Row(
                            children: [
                              FaIcon(FontAwesomeIcons.thumbsDown),
                              SizedBox(
                                width: 5.0,
                              ),
                              Text("Dislike"),
                              SizedBox(
                                width: 5.0,
                              ),
                              Text(dislikeCount.toString()),
                            ],
                          ),
                          onPressed: () {
                            updateDislikeCount();
                          }),
                      CupertinoButton(
                          child: Row(
                            children: [
                              FaIcon(FontAwesomeIcons.shareAlt),
                              SizedBox(
                                width: 5.0,
                              ),
                              Text("Share"),
                            ],
                          ),
                          onPressed: () {
                            shareVideo(this.widget.videourl);
                          }),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(viewCount.toString() + " views"),
                      Text(this.widget.daycount + " days ago"),
                      Text(this.widget.category),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        child: Image.network(avatarUrl),
                      ),
                      Text(this.widget.username),
                      CupertinoButton(
                          child: Text("All Videos"),
                          onPressed: () {
                            openAllVideosPage(this.widget.uid);
                          }),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                hintText: "Comment here..."),
                            onChanged: (String val) {
                              setState(() {
                                commentText = val;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Ink(
                          decoration: ShapeDecoration(
                            shape: CircleBorder(),
                            color: Colors.blue,
                          ),
                          child: IconButton(
                            onPressed: () => {postComment()},
                            splashColor: Colors.blueAccent,
                            icon: Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 600.0,
                    child: ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            child: Image.network(avatarUrl),
                          ),
                          title: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comments[index]['username'].toString(),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                comments[index]['msg'].toString(),
                              ),
                              CupertinoButton(
                                child: Text("Reply"),
                                onPressed: () {},
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
