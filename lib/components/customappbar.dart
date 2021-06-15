import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CustomAppBar extends StatelessWidget {
  final title;
  CustomAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 30, left: 10.0),
            height: 30,
            width: 30,
            child: GestureDetector(
              onTap: () {},
              child: Icon(Icons.menu),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 30, bottom: 0),
            padding: EdgeInsets.all(10),
            child: Text(
              this.title,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 30, right: 10.0),
            height: 30,
            width: 30,
            child: GestureDetector(
              onTap: () {
                print("hello");
              },
              child: Icon(Icons.notifications),
            ),
          ),
        ],
      ),
    );
  }
}
