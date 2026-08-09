import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// A service to handle file uploads to Cloudinary via their REST API.
/// This replaces Firebase Storage due to Spark plan limitations.
class CloudinaryService {
  static const String _cloudName = 'nwrkm85e';
  static const String _uploadPreset = 'mashvira_uploads';
  static const String _uploadUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/auto/upload';

  /// Uploads a [File] to Cloudinary.
  /// Uses an unsigned preset so no API secret is required on the client side.
  /// 
  /// Returns a map containing the Cloudinary response on success (e.g., 'secure_url'),
  /// or null if the upload fails.
  static Future<Map<String, dynamic>?> uploadFile(
    File file, {
    String? folder,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      
      // The preset must be sent as a form field
      request.fields['upload_preset'] = _uploadPreset;
      
      // Optional: organized into folders in your Cloudinary console
      if (folder != null && folder.isNotEmpty) {
        request.fields['folder'] = folder;
      }

      // Add the file
      final multipartFile = await http.MultipartFile.fromPath('file', file.path);
      request.files.add(multipartFile);

      // Execute the request
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(responseData);
        return data; // contains secure_url, public_id, etc.
      } else {
        debugPrint('CloudinaryService: Upload failed with status ${response.statusCode}');
        debugPrint('CloudinaryService Response: $responseData');
        return null;
      }
    } catch (e, st) {
      debugPrint('CloudinaryService: Exception during upload: $e');
      debugPrint('CloudinaryService StackTrace: $st');
      return null;
    }
  }

  /// NOTE ON DELETIONS:
  /// Cloudinary requires the API Secret (which should never be in client code) 
  /// or a signed signature from a backend to delete files. 
  /// Therefore, deleting files directly from the app is not supported.
  /// Instead, we simply remove the file reference from Firestore so it no 
  /// longer appears in the app. A backend clean-up function can be added later.
}
