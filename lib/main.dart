import 'package:flutter/material.dart';

import 'gyrostuff.dart';

void main() =>
  runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Guglu',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const GyroStuff());
  }
}
