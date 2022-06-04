import 'package:flutter/material.dart';
import 'package:flutter_maps/Screens/login/login.dart';
// import 'Screens/map_view/map_state.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Maps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}



// void _markers() {
//   Float _marker_Lat = ;
// }
