import 'package:blackcofferapp/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  int stackIndex = 0;
  String phonoNo = "";
  String username = "";
  String validationId = "";
  String smsCode = ""; // the OTP from user

  Map<String, String> generateNewUser(String uid, String username) {
    Map<String, String> temp = {
      "uid": uid,
      "username": username,
    };
    return temp;
  }

  void saveUserAndLogin(User user) async {
    await FirebaseFirestore.instance
        .collection("users")
        .add(generateNewUser(user.uid, username));
    await SharedPreferences.getInstance().then((instance) => {
          instance.setString("username", username),
          instance.setBool("isLogged", true),
          instance.setString("uid", user.uid),
        });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Login Successfull")));
    Navigator.pushReplacement(
        context, CupertinoPageRoute(builder: (context) => Home()));
  }

  void manualMobileNoAuth() async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: validationId, smsCode: smsCode);
      await FirebaseAuth.instance.signInWithCredential(credential);
      User? currentUser = FirebaseAuth.instance.currentUser!;
      saveUserAndLogin(currentUser);
      Navigator.pushReplacement(
          context, CupertinoPageRoute(builder: (context) => Home()));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Wrong OTP!")));
      print("AUTH FAILED");
      print(e);
    }
  }

  void loginWithMobileNo() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91 " + phonoNo.trim(),
      verificationCompleted: (PhoneAuthCredential credential) async {
        print("login sucess");
        await FirebaseAuth.instance.signInWithCredential(credential);
        User? currentUser = FirebaseAuth.instance.currentUser!;
        saveUserAndLogin(currentUser);
      },
      verificationFailed: (FirebaseAuthException e) {
        print("Exception occured");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("There was an error on OTP sending.")));
      },
      codeSent: (String id, int? resend) async {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("OTP! Sent Successfully !")));
        setState(() {
          validationId = id;
        });
      },
      codeAutoRetrievalTimeout: (String id) {
        print("code timeout");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("OTP Timeout Try again")));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: IndexedStack(
          index: stackIndex,
          children: [
            Column(
              children: [
                SizedBox(height: 90.0),
                SizedBox(
                  height: 180.0,
                  child: FlutterLogo(
                    size: 80.0,
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: "Enter UserName"),
                    onChanged: (String val) {
                      setState(
                        () {
                          username = val;
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: "Enter Mobile Number"),
                    onChanged: (String val) {
                      setState(
                        () {
                          phonoNo = val;
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                CupertinoButton.filled(
                  child: Text("Get Started"),
                  onPressed: () {
                    setState(() {
                      stackIndex = 1;
                    });
                    loginWithMobileNo();
                  },
                ),
              ],
            ),
            // THE OTP SCREEN
            Column(
              children: [
                SizedBox(height: 90.0),
                SizedBox(
                  height: 180.0,
                  child: FlutterLogo(
                    size: 80.0,
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: "Enter OTP here..."),
                    onChanged: (String val) {
                      setState(
                        () {
                          smsCode = val;
                        },
                      );
                    },
                  ),
                ),
                CupertinoButton(
                  child: Text("Did not get OTP, Resend ?"),
                  onPressed: () {
                    loginWithMobileNo();
                  },
                ),
                CupertinoButton.filled(
                  child: Text("Get Started"),
                  onPressed: () {
                    manualMobileNoAuth();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
