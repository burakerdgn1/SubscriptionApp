import 'dart:async';
import 'dart:developer';
import 'dart:io' show Platform;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

// Hasura / GraphQL
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
String staticSubscriptions = """
  query staticSubscriptions {
    type {
      id
      image_url
      name
      price
    }
  }
""";

void main() async {
  await initHiveForFlutter();

  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  firstCamera = cameras.last;

  final _formKey = GlobalKey<FormState>();

  runApp(GraphQLProvider(
    client: client,
    child: MaterialApp(
      title: 'Subscription App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginForm(formKey: _formKey),
    ),
  ));
}

class LoginForm extends StatefulWidget {
  LoginForm({
    Key? key,
    required GlobalKey<FormState> formKey,
  })  : _formKey = formKey,
        super(key: key);

  final GlobalKey<FormState> _formKey;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final emailController = TextEditingController()..text = "tolga@tolga.com";
  final passwordController = TextEditingController()..text = "tolga123";

  late bool _success;
  late String _userEmail;

  Future<bool> Login(String email, String password) async {
    try {
      final FirebaseUser user = (await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ))
          .user;

      if (user != null) {
        setState(() {
          _success = true;
          _userEmail = user.email;
        });
        log("Found User: " + user.email);
      } else {
        setState(() {
          _success = false;
        });
      }
    } on Exception catch (_) {
      log("User Not Found: " + email);
      _success = false;
    }
    return _success;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: widget._formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: "email",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: "Password",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (widget._formKey.currentState!.validate()) {
                      var result = await Login(
                          emailController.text, passwordController.text);
                      if (result) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomePage()),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Logged in successfully.')));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Invalid email or password.')));
                      }
                    }
                  },
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ignore: non_constant_identifier_names
  int user_id = 1;

  String GetSubscriptions(userid) {
    return """
      query GetSubscriptions {
      subscriptions(where: {user: {_eq: $userid}}) {
          id
          subscriptionInfo {
            id
            image_url
            name
            price
          }
        }
      }
    """;
  }

  Future<Object> CheckSubscriptionValidation(
      String subID, String userID) async {
    try {
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
        return {"openDoor": false, "validUntil": ""};
      } else {
        var subData = result.data?['subscriptions'][0];
        var validUntil = subData['valid_until'];
        log('validUntil: $validUntil');
        var currentDate = DateTime.now();
        var openDoor = DateTime.parse(validUntil).millisecondsSinceEpoch >
            currentDate.millisecondsSinceEpoch;
        return {"openDoor": openDoor, "validUntil": validUntil};
      }
    } on Exception {
      return {"openDoor": false, "validUntil": ""};
    }
  }

  GenerateQRCode(int SubscriptionID, int userID) async {
    var subData = await CheckSubscriptionValidation(
        SubscriptionID.toString(), userID.toString()) as Map;

    var openDoor = subData["openDoor"];
    var validUntil = subData["validUntil"];
    var qrData = '$SubscriptionID:$userID:$openDoor:$validUntil';
    // TODO: Encrypt qrData before creating QR-Code.
    log('data: $qrData');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRCodePage(qrData)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Homepage"),
      ),
      body: Query(
        options: QueryOptions(
          document:
              true ? gql(GetSubscriptions(user_id)) : gql(staticSubscriptions),
          pollInterval: const Duration(seconds: 10),
        ),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return const Text('Loading');
          }

          List subscriptions = result.data?['subscriptions'];

          return ListView.builder(
              itemCount: subscriptions.length,
              itemBuilder: (context, index) {
                final subscription =
                    subscriptions[index]['subscriptionInfo'][0];

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.network(subscription['image_url'],
                            height: 75, width: 75, fit: BoxFit.contain),
                        Text(subscription['name']),
                        ElevatedButton(
                          onPressed: () => GenerateQRCode(
                              subscriptions[index]['id'], user_id),
                          child: const Text("QR Code"),
                        ),
                      ]),
                );
              });
        },
      ),
    );
  }
}

class QRCodePage extends StatelessWidget {
  QRCodePage(this.qrData);
  final String qrData;

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
                data: qrData,
                version: QrVersions.auto,
                size: 200.0,
              ),
              const Text("Show this code to scanner of gate")
            ],
          ),
        ));
  }
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
      setState(() {
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
                          future: CheckSubscriptionValidation(result!.code),
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
