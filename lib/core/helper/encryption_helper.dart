import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

final String _secretKey = "secretkey";

class FileEncryptor {
  static final key = encrypt.Key.fromUtf8("Bal3xCAiQREPGg3lqiEXooZtGF9D4DGI");
  static final iv = encrypt.IV.fromUtf8("VridheeProj121");

  encrypt.Encrypter getEncryptor(){
    return  encrypt.Encrypter(encrypt.AES(key));
  }

  Future<void> encryptFile(File file, String outputFilePath) async {
    print('File downloaded! And Encryption Started');

    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final fileBytes = await file.readAsBytes();
    final encrypted = encrypter.encryptBytes(fileBytes, iv: iv);

    final outputFile =
        File(outputFilePath);

    await outputFile.writeAsBytes(encrypted.bytes);
    print("file Encrypted successfully");
  }

  Future<Uint8List> decryptFile(File file) async {
    final encrypter = encrypt.Encrypter(encrypt.AES(
      key,
    ));
    final fileBytes = await file.readAsBytes();
    final decrypted =
        encrypter.decryptBytes(encrypt.Encrypted(fileBytes), iv: iv);
    return Uint8List.fromList(decrypted);
  }
}
