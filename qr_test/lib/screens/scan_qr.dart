// ignore_for_file: import_of_legacy_library_into_null_safe, deprecated_member_use, file_names, prefer_const_constructors

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../AESEncryption.dart';

class ScanQR extends StatefulWidget {


  @override
  _ScanQRState createState() => _ScanQRState();
}

String qrData = "No data found!";
var data;
bool hasdata = false;

class _ScanQRState extends State<ScanQR> {
  AESEncryption aesEncryption = new AESEncryption();
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "Scan QR",
      child: Scaffold(
        appBar: AppBar(
          title: Text("QR Scanner"),
        ),
        // ignore: sized_box_for_whitespace
        body: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      "Raw Data:  ${(qrData)}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.launch_outlined),
                    onPressed: hasdata
                        ? () async {
                            if (await canLaunch(qrData)) {
                              print(qrData);
                              await launch(qrData);
                            } else {
                              throw 'Could not launch ';
                            }
                          }
                        : null,
                  ),
                ],
              ),
              SizedBox(height: 15),
              Container(
                height: 35,
                child: OutlineButton(
                  
                  child: Text(
                    "Scan QR",
                    style: TextStyle(fontSize: 17),
                  ),
                  onPressed: () async {
                    var options = ScanOptions(
                      autoEnableFlash: true,
                    );
                    var data = await BarcodeScanner.scan(options: options);
                    setState(() {
                      qrData = data.toString();
                      hasdata = true;
                      qrData = aesEncryption
                          .decryptMsg(aesEncryption.getCode(qrData))
                          .toString();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}