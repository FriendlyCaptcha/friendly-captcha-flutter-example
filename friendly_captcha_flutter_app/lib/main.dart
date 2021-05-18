import 'package:flutter/material.dart';

import 'friendlycaptcha.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Friendly Captcha Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Friendly Captcha Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  final String friendlyCaptchaSitekey = "<your sitekey>";
  String captchaSolution = ".UNSET";

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  void _captchaCallback(String solution) {
    print("The captcha was completed: " + solution);
    widget.captchaSolution = solution;
  }

  void _buttonPress() {
    if (widget.captchaSolution == ".UNSET") { // The captcha wasn't completed
      Fluttertoast.showToast(
          msg: "You haven't completed the anti-robot check.",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0
      );
    } else {
      // In a real application we would send the captcha solution to our server
      // for verification (along with data that makes sense for your application).
      // In this demo app we show the string we would send to the server in a Toast.
      Fluttertoast.showToast(
          msg: "You completed the captcha, now it should be verified.\n\nYour solution was: " + widget.captchaSolution,
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FriendlyCaptcha(
                callback: _captchaCallback,
                sitekey: widget.friendlyCaptchaSitekey,
            ),
            ElevatedButton(
              onPressed: _buttonPress,
              child: Text("Submit"),
            )
          ],
        ),
      ),
    );
  }
}
