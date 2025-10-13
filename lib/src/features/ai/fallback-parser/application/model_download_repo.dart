import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma_interface.dart';
import 'package:http/http.dart' as http;
import 'package:namma_wallet/src/features/ai/fallback-parser/domain/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service responsible for handling model downloads,
/// including managing file paths and license information.
class ModelDownloadService {
  /// Creates a new [ModelDownloadService] with the required
  /// model URL, filename, and license URL.
  ModelDownloadService({
    required this.modelUrl,
    required this.modelFilename,
    required this.licenseUrl,
  });

  /// The URL pointing to the remote model file to be downloaded.
  final String modelUrl;

  /// The local filename used to save the downloaded model.
  final String modelFilename;

  /// The URL pointing to the license associated with this model.
  final String licenseUrl;

  /// Load the token from SharedPreferences.
  Future<String?> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Save the token to SharedPreferences.
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /// Helper method to get the file path.
  Future<String> getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$modelFilename';
  }

  /// Checks if the model file exists and matches the remote file size.
  Future<bool> checkModelExistence(String token) async {
    try {
      final filePath = await getFilePath();
      final file = File(filePath);

      final headers = token.isNotEmpty
          ? {'Authorization': 'Bearer $token'}
          : <String, String>{};

      final headResponse =
          await http.head(Uri.parse(modelUrl), headers: headers);

      if (headResponse.statusCode == 200) {
        final contentLengthHeader = headResponse.headers['content-length'];
        if (contentLengthHeader != null) {
          final remoteFileSize = int.parse(contentLengthHeader);
          if (file.existsSync() && await file.length() == remoteFileSize) {
            return true;
          }
        }
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Error checking model existence: $e');
      }
    }
    return false;
  }

  /// Downloads the model file and tracks progress.
  Future<void> downloadModel({
    required String token,
    required Function(double) onProgress,
  }) async {
    try {
      final stream = FlutterGemmaPlugin.instance.modelManager
          .downloadModelFromNetworkWithProgress(
        modelUrl,token: AIConstants.HUGGING_FACE_KEY
      );

      await for (final progress in stream) {
        onProgress(progress.toDouble());
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading model: $e');
      }
      rethrow;
    }
  }

  /// Deletes the downloaded file.
  Future<void> deleteModel() async {
    try {
      final filePath = await getFilePath();
      final file = File(filePath);

      if (file.existsSync()) {
        await file.delete();
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Error deleting model: $e');
      }
    }
  }
}
