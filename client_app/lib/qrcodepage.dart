import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodePage extends StatelessWidget {
  QRCodePage(this.qrData);
  final Future<String> qrData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("QR Code"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QrImage(
                data: qrData.toString(),
                version: QrVersions.auto,
                size: 200.0,
              ),
              const Text("Show this code to scanner of gate")
            ],
          ),
        ));
  }
}
