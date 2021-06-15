import 'dart:convert';
import 'dart:typed_data';

import 'package:blackcofferapp/components/customappbar.dart';
import 'package:blackcofferapp/components/videocard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Explore extends StatefulWidget {
  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  String searchParam = "";

  String calulateDifference(String formattedString) {
    DateTime date = DateTime.parse(formattedString);
    int diff = DateTime.now().difference(date).inDays;
    return diff.toString();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        hintText: "Search Videos"),
                    onChanged: (String val) {
                      setState(() {
                        searchParam = val;
                      });
                      print(searchParam);
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
                    onPressed: () => {},
                    splashColor: Colors.blueAccent,
                    icon: Icon(
                      Icons.filter_alt,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: searchParam.length != 0
                  ? FirebaseFirestore.instance
                      .collection("videos")
                      .where("searchword",
                          isLessThanOrEqualTo: searchParam
                              .toLowerCase()
                              .replaceAll(new RegExp(r"\s+"), ""),
                          isGreaterThanOrEqualTo: searchParam
                              .toLowerCase()
                              .replaceAll(new RegExp(r"\s+"), ""),
                          isEqualTo: searchParam
                              .toLowerCase()
                              .replaceAll(new RegExp(r"\s+"), ""))
                      .snapshots()
                  : FirebaseFirestore.instance.collection("videos").snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  print(snapshot.data.docs.length);
                  return ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      var currentshot = snapshot.data.docs[index];
                      return VideoCard(
                        thumbnail: Uint8List.fromList(
                          json.decode(currentshot['thumbnail']).cast<int>(),
                        ),
                        id: currentshot.id,
                        videourl: currentshot['url'],
                        uid: currentshot['uploadedby'],
                        username: currentshot['username'],
                        comments: currentshot['comments'],
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
