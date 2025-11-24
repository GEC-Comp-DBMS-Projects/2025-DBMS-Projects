import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class JobApplicationService {
  static const String baseUrl = "https://campusnest-backend-lkue.onrender.com/api/v1/student/jobs";

  // Get auth token from SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> applyForJob(BuildContext context, String jobId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      _showSnackBar(context, "Not logged in. Please login first.");
      return;
    }

    final url = Uri.parse("$baseUrl/$jobId/apply");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _showSnackBar(context, data["message"] ?? "Application submitted successfully");
      } else {
        final error = jsonDecode(response.body);
        _showSnackBar(context, error["error"] ?? "Failed to apply");
      }
    } catch (e) {
      _showSnackBar(context, "Error: $e");
    }
  }

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
