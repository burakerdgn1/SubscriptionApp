import 'dart:developer';

import 'package:flutter/material.dart';

import '../api/api.dart';

// ignore: non_constant_identifier_names
Future<String> GenerateQRCode(int SubscriptionID, int userID) async {
  var subData = await CheckSubscriptionValidation(
      SubscriptionID.toString(), userID.toString()) as Map;

  var openDoor = subData["openDoor"];
  var validUntil = subData["validUntil"];
  var qrData = '$SubscriptionID:$userID:$openDoor:$validUntil';

  // TODO: Encrypt qrData before creating QR-Code.
  log('data: $qrData');
  return qrData;
}
