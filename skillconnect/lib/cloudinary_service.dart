import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class CloudinaryService {
  static const String _cloudName = "";
  static Future<Response> uploadFile(
    Uint8List fileBytes,
    String fileName, {
    String resourceType = 'auto',
  }) async {
    // The Cloudinary upload URL.
    final String uploadUrl =
        "https://api.cloudinary.com/v1_1/$_cloudName/$resourceType/upload";

    // Create the FormData for the POST request.
    final FormData formData = FormData.fromMap({
      "file": MultipartFile.fromBytes(fileBytes, filename: fileName),
      "upload_preset": "skillconnect",
    });

    try {
      // Make the POST request using Dio.
      final dio = Dio();
      final response = await dio.post(
        uploadUrl,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
      return response;
    } on DioException catch (e) {
      if (kDebugMode) {
        print("Cloudinary upload error: ${e.response?.data ?? e.message}");
      }
      throw Exception(
        "Failed to upload file. Server said: ${e.response?.data?['error']?['message'] ?? e.message}",
      );
    } catch (e) {
      if (kDebugMode) {
        print("Unexpected error during upload: $e");
      }
      throw Exception("An unexpected error occurred: $e");
    }
  }
}
