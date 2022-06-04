import 'package:flutter/material.dart';
import 'package:flutter_maps/Screens/map_view/map_state.dart';
import 'package:flutter_maps/Screens/register/register.dart';
import 'package:flutter_maps/components/background.dart';
import 'dart:ui' as ui;

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Background(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // AppBar(
            //   title: Text("FindBear"),
            // ),
            Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: AppBar(
                    toolbarHeight: 35,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(360)),
                    elevation: 2.00,
                    title: Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          "FindBear",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 40,

                            // foreground: Paint()
                            //   ..shader = ui.Gradient.linear(
                            //     const Offset(0, 20),
                            //     const Offset(150, 20),
                            //     <Color>[
                            //       Colors.blueGrey,
                            //       Colors.blueAccent,
                            //     ],
                          ),
                        )))),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 160),
              child: Text(
                "LOGIN",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2661FA),
                    fontSize: 24),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: size.height * 0.03),
            Container(
              alignment: Alignment.centerRight,
              margin: EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                decoration: InputDecoration(labelText: "Username"),
              ),
            ),
            SizedBox(height: size.height * 0.03),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: Text(
                "Forgot your password?",
                style: TextStyle(fontSize: 12, color: Color(0XFF2661FA)),
              ),
            ),
            SizedBox(height: size.height * 0.05),
            Container(
              alignment: Alignment.centerRight,
              margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: RaisedButton(
                onPressed: () {},
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80.0)),
                textColor: Colors.white,
                padding: const EdgeInsets.all(0),
                child: Container(
                  alignment: Alignment.center,
                  height: 50.0,
                  width: size.width * 0.5,
                  decoration: new BoxDecoration(
                      borderRadius: BorderRadius.circular(80.0),
                      gradient: new LinearGradient(colors: [
                        Color.fromARGB(255, 255, 136, 34),
                        Color.fromARGB(255, 255, 177, 41)
                      ])),
                  padding: const EdgeInsets.all(0),
                  child: Text(
                    "LOGIN",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              margin: EdgeInsets.symmetric(horizontal: 40, vertical: 2),
              child: RaisedButton(
                onPressed: () => {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MapView()))
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80.0)),
                textColor: Colors.white,
                padding: const EdgeInsets.all(0),
                child: Container(
                  alignment: Alignment.center,
                  height: 50.0,
                  width: size.width * 0.5,
                  decoration: new BoxDecoration(
                      borderRadius: BorderRadius.circular(80.0),
                      gradient: new LinearGradient(colors: [
                        Color.fromARGB(255, 255, 136, 34),
                        Color.fromARGB(255, 255, 177, 41)
                      ])),
                  padding: const EdgeInsets.all(0),
                  child: Text(
                    "Continue without login",
                    textAlign: TextAlign.center,
                    // style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: GestureDetector(
                onTap: () => {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()))
                },
                child: Text(
                  "Don't Have an Account? Sign up",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2661FA)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
