// ignore_for_file: non_constant_identifier_names

import 'package:camera/camera.dart';
import 'package:client_app/home.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:graphql_flutter/graphql_flutter.dart';
import './api/api.dart';

import './login.dart';

var firstCamera;

void main() async {
  await initHiveForFlutter();
  await GetStorage.init();

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
      //home: LoginForm(formKey: _formKey),
      home:
          await IsLoggedIn() ? const HomePage() : LoginPage(formKey: _formKey),
    ),
  ));
}
/* 
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
  int user_id = 1;

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
          document: true ? GetSubscriptions(user_id) : gql(staticSubscriptions),
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
                          future:
                              CheckSubscriptionValidationString(result!.code),
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
 */