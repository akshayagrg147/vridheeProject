import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teaching_app/core/helper/encryption_helper.dart';

class DecryptImageView extends StatefulWidget {
  final String path;
  const DecryptImageView({super.key, required this.path});

  @override
  State<DecryptImageView> createState() => _DecryptImageViewState();
}

class _DecryptImageViewState extends State<DecryptImageView> {
  bool isLoading = false;
  Uint8List? imageBuffer;
  decryptImage() async {
    if (widget.path.isEmpty) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    final file = File(widget.path);
    if (await file.exists()) {
      imageBuffer = await FileEncryptor().decryptFile(file);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    decryptImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return imageBuffer != null
        ? Image.memory(
            imageBuffer!,
            fit: BoxFit.fitHeight,
          )
        : const SizedBox.shrink();
  }
}
