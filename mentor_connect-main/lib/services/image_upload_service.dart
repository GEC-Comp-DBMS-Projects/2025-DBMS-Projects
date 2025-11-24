import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

/// Image Upload Service - Firebase Storage Alternative
///
/// This service provides FREE image hosting using ImgBB API
/// No Firebase Storage needed! Perfect for college projects.
///
/// Free tier: Unlimited images, 32MB per image
class ImageUploadService {
  // ImgBB API Key - Get yours FREE at https://api.imgbb.com/
  // For demo purposes, using a temporary key - REPLACE WITH YOUR OWN!
  static const String _apiKey = '8db45818a9aa69a4c401d231a959b40d';
  static const String _uploadUrl = 'https://api.imgbb.com/1/upload';

  /// Upload image to ImgBB and get URL
  /// Returns the image URL that can be stored in Firestore
  Future<String?> uploadImage(File imageFile, {String? name}) async {
    try {
      // Read image file
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Make API request
      final response = await http.post(
        Uri.parse(_uploadUrl),
        body: {
          'key': _apiKey,
          'image': base64Image,
          'name': name ?? 'mentorship_${DateTime.now().millisecondsSinceEpoch}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Return the URL
        return data['data']['url'] as String?;
      } else {
        print('ImgBB upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Upload image from bytes (for web or when you already have bytes)
  Future<String?> uploadImageBytes(Uint8List bytes, {String? name}) async {
    try {
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(_uploadUrl),
        body: {
          'key': _apiKey,
          'image': base64Image,
          'name': name ?? 'mentorship_${DateTime.now().millisecondsSinceEpoch}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['url'] as String?;
      } else {
        print('ImgBB upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Alternative: Store small images directly in Firestore as base64
  /// Use this ONLY for very small images (< 100KB) like avatars
  /// Firestore has 1MB document size limit
  Future<String> imageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return 'data:image/png;base64,${base64Encode(bytes)}';
  }

  /// Check if API key is configured
  bool isConfigured() {
    return _apiKey != 'YOUR_IMGBB_API_KEY_HERE' && _apiKey.isNotEmpty;
  }

  /// Get setup instructions
  String getSetupInstructions() {
    return '''
    ImgBB Setup (FREE - 2 minutes):
    
    1. Visit: https://api.imgbb.com/
    2. Click "Get API Key" (free, no credit card)
    3. Sign up with email
    4. Copy your API key
    5. Replace 'YOUR_IMGBB_API_KEY_HERE' in image_upload_service.dart
    
    That's it! Unlimited free image hosting for your project!
    ''';
  }
}

/// Alternative Option 2: Cloudinary (25GB free)
class CloudinaryUploadService {
  // Get free account at https://cloudinary.com
  static const String _cloudName = 'YOUR_CLOUD_NAME';
  static const String _uploadPreset = 'YOUR_UPLOAD_PRESET';

  Future<String?> uploadImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload'),
        body: {
          'file': 'data:image/png;base64,$base64Image',
          'upload_preset': _uploadPreset,
          'folder': 'mentorship_app',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['secure_url'] as String?;
      } else {
        print('Cloudinary upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  bool isConfigured() {
    return _cloudName != 'YOUR_CLOUD_NAME' &&
        _uploadPreset != 'YOUR_UPLOAD_PRESET';
  }

  String getSetupInstructions() {
    return '''
    Cloudinary Setup (FREE - 5 minutes):
    
    1. Visit: https://cloudinary.com
    2. Sign up for free account (25GB storage!)
    3. Go to Dashboard
    4. Copy your "Cloud Name"
    5. Go to Settings → Upload → Add upload preset
    6. Create unsigned preset, copy the name
    7. Replace values in cloudinary_upload_service.dart
    
    Free tier: 25GB storage, 25GB bandwidth/month
    ''';
  }
}

/// Simple service selector - picks the configured service
class StorageService {
  static final _imgbb = ImageUploadService();
  static final _cloudinary = CloudinaryUploadService();

  /// Upload image using available service
  static Future<String?> uploadImage(File imageFile, {String? name}) async {
    // Try ImgBB first (simpler setup)
    if (_imgbb.isConfigured()) {
      return await _imgbb.uploadImage(imageFile, name: name);
    }

    // Try Cloudinary if configured
    if (_cloudinary.isConfigured()) {
      return await _cloudinary.uploadImage(imageFile);
    }

    // No service configured
    print('No image upload service configured!');
    print(_imgbb.getSetupInstructions());
    return null;
  }

  /// Convert to base64 for small images (< 100KB)
  static Future<String> imageToBase64(File imageFile) async {
    return await _imgbb.imageToBase64(imageFile);
  }

  /// Check if any service is ready
  static bool isReady() {
    return _imgbb.isConfigured() || _cloudinary.isConfigured();
  }

  /// Get setup status message
  static String getStatus() {
    if (_imgbb.isConfigured()) return 'ImgBB configured ✓';
    if (_cloudinary.isConfigured()) return 'Cloudinary configured ✓';
    return 'No image service configured. See STORAGE_WORKAROUND.md';
  }
}
