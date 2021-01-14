import 'package:flutter/material.dart';
import 'package:smartid_map/home_page.dart';
import 'package:smartid_map/login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geolocation Google Maps Demo',
      home: HomePage(),
    );
  }
}
