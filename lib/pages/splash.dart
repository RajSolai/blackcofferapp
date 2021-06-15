import 'package:blackcofferapp/home.dart';
import 'package:blackcofferapp/pages/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool? isLogged = false;

  _navigator() async {
    await Future.delayed(Duration(seconds: 3));
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    isLogged = _prefs.getBool("isLogged");
    print(isLogged);
    if (isLogged == null) {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder: (context) => Login(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder: (context) => Home(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _navigator();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
