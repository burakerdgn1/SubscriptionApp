// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CreatedQR extends StatefulWidget {
  final myQR;

  const CreatedQR(this.myQR);

  @override
  _CreatedQRState createState() => _CreatedQRState();
}

class _CreatedQRState extends State<CreatedQR> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Created QR "),
      ),
      body: Center(
        child: QrImage(
          data: widget.myQR,
          version: QrVersions.auto,
          size: 250.0,
          gapless: false,
        ),
      ),
    );
  }
} 