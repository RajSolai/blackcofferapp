import 'dart:convert';
import 'dart:typed_data';

import 'package:blackcofferapp/components/customappbar.dart';
import 'package:blackcofferapp/components/videocard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserVid extends StatelessWidget {
  final uid, user;
  const UserVid({Key? key, required this.uid, required this.user})
      : super(key: key);

  String calulateDifference(String formattedString) {
    DateTime date = DateTime.parse(formattedString);
    int diff = DateTime.now().difference(date).inDays;
    return diff.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: "Videos of " + this.user),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("videos")
                  .where("uploadedby", isEqualTo: this.uid)
                  .snapshots(),
              builder: (context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      var currentshot = snapshot.data!.docs[index];
                      return VideoCard(
                        thumbnail: Uint8List.fromList(
                          json.decode(currentshot['thumbnail']).cast<int>(),
                        ),
                        videourl: currentshot['url'],
                        uid: currentshot['uploadedby'],
                        username: currentshot['username'],
                        videoviews: int.tryParse(currentshot['views']),
                        likes: int.tryParse(currentshot['likes']),
                        dislikes: int.tryParse(currentshot['dislikes']),
                        daycount: calulateDifference(currentshot['uploaddate']),
                        category: currentshot['category'],
                        location: currentshot['location'],
                        title: currentshot['title'],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
