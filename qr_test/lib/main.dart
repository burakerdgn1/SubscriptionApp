// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'screens/create_QR.dart';
import 'screens/scan_QR.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      //home: MyHomePage(title: "Scan and create QR code"),
      routes: {
        '/': (context)=> MyHomePage(title: "Qr Code Test"),
        // When navigating to the "/" route, build the FirstScreen widget.
        '/create': (context) =>  CreateQR(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/scan': (context) =>  ScanQR(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
          ),
        ),
        body: Center(
            child: Column(
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/create');
              },
              child: Text("Create Qr Code"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/scan');
              },
              child: Text("Scan Qr Code"),
            ),
          ],
        )));
  }
}
