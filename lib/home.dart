import 'package:blackcofferapp/pages/Explore.dart';
import 'package:blackcofferapp/pages/recordvid.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Home extends StatefulWidget {
  final searchKey;
  Home({this.searchKey});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _index = 0;

  final _screens = [
    Center(
      child: Explore(),
    ),
    Center(
      child: Recorder(),
    ),
    Center(
      child: Explore(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: _index,
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
          setState(() {
            _index = index;
          });
        },
      ),
    );
  }
}
