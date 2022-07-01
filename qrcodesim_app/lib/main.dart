import 'dart:async';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io' show Platform;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'AESEncryption.dart';

final HttpLink httpLink = HttpLink(
  'https://abonelik-app.hasura.app/v1/graphql',
);

final AuthLink authLink = AuthLink(
    getToken: () async =>
        'KoplvKhAjqPNC8Ax5Odi7f1j8ZnCptKUZx0s6n2RsfoTHqzsQA8bgNGKpXOr48Us',
    headerKey: 'x-hasura-admin-secret');

final Link link = authLink.concat(httpLink);

var graphQLClient = GraphQLClient(
  cache: GraphQLCache(store: HiveStore()),
  link: link,
);

ValueNotifier<GraphQLClient> client = ValueNotifier(
  graphQLClient,
);

var firstCamera;

void main() async {
  await initHiveForFlutter();

  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  firstCamera = cameras.last;

  runApp(GraphQLProvider(
    client: client,
    child: MaterialApp(
      title: 'Subscription App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DoorSimulation(
        camera: firstCamera,
      ),
    ),
  ));
}

class DoorSimulation extends StatefulWidget {
  const DoorSimulation({Key? key, required this.camera}) : super(key: key);

  final CameraDescription camera;

  @override
  State<DoorSimulation> createState() => _DoorSimulationState();
}

class _DoorSimulationState extends State<DoorSimulation> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  QRViewController? controller;
  Barcode? result;
  bool checked = false;
  String? decryptedString;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      var decrypted;
      try {
        decrypted = AESEncryption.decryptString(scanData.code as String);
        debugPrint('decrypt success : $decryptedString');
      } catch (exception) {
        debugPrint('Cannot process the scanned QR');
        controller.resumeCamera();
      }
      setState(() {
        decryptedString = decrypted;
        result = scanData;
        checked = true;
      });
    });
  }

  // ignore: non_constant_identifier_names
  Future<String> CheckSubscriptionValidation(String? data) async {
    try {
      List<String>? splitData = data?.split(":");
      if (splitData != null && splitData.length > 1) {
        String subID = splitData[0];
        String userID = splitData[1];

        var queryString = """
          query MyQuery {
            subscriptions(where: {id: {_eq: $subID}, user: {_eq: $userID}}, limit: 1) {
              id
              valid_until
            }
          }
        """;
        var result = await graphQLClient.query(QueryOptions(
          document: gql(queryString),
        ));
        if (result.data?['subscriptions'].length == 0) {
          return "Subscription not found.";
        } else {
          var subData = result.data?['subscriptions'][0];
          return "Valid Until: " + subData['valid_until'];
        }
      } else {
        return "Subscription date is invalid.";
      }
    } on Exception {
      return "QR Code is invalid.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("DOOR SIM"),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: !checked
                  ? QRView(
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                    )
                  : ElevatedButton(
                      onPressed: () => {
                        setState(() {
                          checked = false;
                        })
                      },
                      child: const Text("Scan Again"),
                    ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                  child: result != null
                      ? FutureBuilder(
                          future: CheckSubscriptionValidation(decryptedString),
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
                            return Text(
                                snapshot.data != null ? snapshot.data : "");
                          })
                      : const Text("Scan a code")),
            )
          ],
        ),
      ),
    );
  }
}
