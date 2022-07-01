// ignore_for_file: file_names

import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' as f;

class AESEncryption {
  //These are for creating unique key and iv for every user in the future
  //static final Uint8List keyFromList = Uint8List.fromList([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]);
  //static final Uint8List ivList = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]);
  //static final Key key = Key.fromUtf8(keyFromList.toString());
  //static final IV iv1 = IV.fromUtf8(ivList.toString());

  static const String keyString = "Key";
  static const String ivString = "Iv";

  static final Key key = Key.fromUtf8(keyString);
  static final Encrypter encrypter = Encrypter(AES(key));
  static final IV iv = IV.fromUtf8(ivString);

  static String encryptString(String originalText) {
    return encrypter.encrypt(originalText, iv: iv).base64;
  }

  static String decryptString(String encryptedText) {
    try {
      final text =
          encrypter.decrypt(Encrypted.fromBase64(encryptedText), iv: iv);
      f.debugPrint('decrypted Text: $text');
      return text;
    } catch (e) {
      rethrow;
    }
  }
}
