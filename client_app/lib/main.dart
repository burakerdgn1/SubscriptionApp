// ignore_for_file: non_constant_identifier_names

import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:client_app/home.dart';
import 'package:client_app/product_detail.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
        debugShowCheckedModeBanner: false,
        title: 'Subscription App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: await IsLoggedIn()
            ? const HomePage()
            : LoginPage(formKey: _formKey),
      )));
}
