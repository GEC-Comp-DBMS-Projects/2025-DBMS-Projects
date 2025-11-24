// uploading files to cloudinary
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import "package:http/http.dart" as http;
import 'package:image_picker/image_picker.dart';

Future<String?> uploadToCloudinary(XFile? xFile, [Uint8List? webBytes]) async {
  // 1. Load credentials from .env file
  final String? cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
  final String? uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

  // 2. Check if credentials are loaded correctly
  if (cloudName == null || uploadPreset == null) {
    print("❌ Error: Cloudinary credentials (cloud_name or upload_preset) not found in .env file.");
    return null;
  }
  
  // 3. Check if a file was actually selected
  if (xFile == null && webBytes == null) {
    print("No file selected!");
    return null;
  }
  
  // 4. Build the request
  final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
  final request = http.MultipartRequest("POST", uri);

  // Add the upload preset to the request fields
  request.fields['upload_preset'] = uploadPreset;

  // 5. Attach the file
  http.MultipartFile multipartFile;
  if (webBytes != null) {
    // For Flutter Web
    multipartFile = http.MultipartFile.fromBytes('file', webBytes, filename: "upload.jpg");
  } else {
    // For Mobile
    final fileBytes = await xFile!.readAsBytes();
    multipartFile = http.MultipartFile.fromBytes('file', fileBytes, filename: xFile.name);
  }
  request.files.add(multipartFile);

  // 6. Send request and handle response
  try {
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(responseBody);
      print("✅ Upload successful: ${jsonResponse['secure_url']}");
      return jsonResponse["secure_url"];
    } else {
      print("❌ Upload failed with status: ${response.statusCode}");
      print("Cloudinary Response: $responseBody");
      return null;
    }
  } catch (e) {
    print("An error occurred while uploading: $e");
    return null;
  }
}