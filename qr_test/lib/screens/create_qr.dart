// ignore_for_file: unnecessary_new, prefer_const_constructors, deprecated_member_use, avoid_unnecessary_containers, prefer_const_constructors_in_immutables, sized_box_for_whitespace, file_names

import 'package:flutter/material.dart';
import 'package:qr_test/AESEncryption.dart';

import 'created_QR.dart';

class CreateQR extends StatefulWidget {
  @override
  _CreateQRState createState() => _CreateQRState();
}

TextEditingController mycontroller = new TextEditingController();

class _CreateQRState extends State<CreateQR> {
  AESEncryption aesEncryption = new AESEncryption();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QR Creator"),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: TextFormField(
                controller: mycontroller,
                decoration: InputDecoration(
                  labelText: "Enter the data for creating a QR",
                ),
                onEditingComplete: () {
                  print(mycontroller.text);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreatedQR(mycontroller.text)));
                },
              ),
            ),
            Container(
              height: 35,
              child: OutlineButton(
                child: Text(
                  "Create QR",
                  style: TextStyle(fontSize: 17),
                ),
                onPressed: () {
                  print(mycontroller.text);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreatedQR(aesEncryption.encryptMsg(mycontroller.text).base16)));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
