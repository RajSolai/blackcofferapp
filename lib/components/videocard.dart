import 'package:blackcofferapp/pages/videoplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VideoCard extends StatelessWidget {
  final String avatarUrl =
      "https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png";
  final thumbnail,
      title,
      videourl,
      videoviews,
      likes,
      dislikes,
      comments,
      daycount,
      location,
      id,
      category,
      username,
      uid;
  const VideoCard(
      {this.thumbnail,
      this.title,
      this.videourl,
      this.daycount,
      this.id,
      this.uid,
      this.location,
      this.comments,
      this.username,
      this.category,
      this.videoviews,
      this.likes,
      this.dislikes});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => VideoPlayerView(
              title: this.title,
              videourl: this.videourl,
              uid: this.uid,
              id: this.id,
              views: this.videoviews,
              likes: this.likes,
              comments: this.comments,
              dislikes: this.dislikes,
              category: this.category,
              daycount: this.daycount,
              username: this.username,
            ),
          ),
        );
      },
      child: Card(
        child: Column(
          children: [
            Container(
              child: Container(
                height: 200.0,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: MemoryImage(thumbnail),
                  fit: BoxFit.cover,
                )),
              ),
            ),
            Container(
              child: Column(
                children: [
                  SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        child: Image.network(avatarUrl),
                      ),
                      Text(this.title),
                      Text(this.location),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(this.username),
                      Text(this.videoviews.toString() + " Views"),
                      Text(this.daycount + " days ago"),
                      Text(this.category),
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
