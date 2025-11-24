import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload image (mobile: File path)
  Future<String?> uploadImage(String path, BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Uploading image...")),
    );
    try {
      File file = File(path);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      Reference ref = _storage.ref().child("shop_images/$fileName");
      UploadTask uploadTask = ref.putFile(file);

      await uploadTask;
      String downloadURL = await ref.getDownloadURL();
      debugPrint("Download URL (mobile): $downloadURL");
      return downloadURL;
    } catch (e) {
      debugPrint("Error uploading image (mobile): $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
      return null;
    }
  }

  /// Upload image (web: Uint8List bytes)
  Future<String?> uploadImageWeb(
      Uint8List bytes, String fileName, BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Uploading image...")),
    );
    try {
      String uniqueName = DateTime.now().millisecondsSinceEpoch.toString();

      Reference ref =
          _storage.ref().child("shop_images/$uniqueName-$fileName");

      UploadTask uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: "image/jpeg"),
      );

      await uploadTask;
      String downloadURL = await ref.getDownloadURL();
      debugPrint("Download URL (web): $downloadURL");
      return downloadURL;
    } catch (e) {
      debugPrint("Error uploading image (web): $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
      return null;
    }
  }
}
