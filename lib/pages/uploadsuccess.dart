import 'package:blackcofferapp/components/customappbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../home.dart';

class UploadSuccess extends StatelessWidget {
  const UploadSuccess({Key? key}) : super(key: key);

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
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => Home(),
            ),
          );
        },
      ),
      body: Container(
        child: Column(
          children: [
            CustomAppBar(
              title: "Upload Video",
            ),
            SizedBox(
              height: 280,
            ),
            Center(
              child: Text(
                "Your Video Posted Successfully",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
