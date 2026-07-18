import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_config.dart';
import 'auth_service.dart';

/// Firebase Storage service for file uploads
class StorageService {
  static final FirebaseStorage _storage = FirebaseConfig.storage;
  static final FirebaseCrashlytics _crashlytics = FirebaseConfig.crashlytics;

  /// Upload PDF report to Firebase Storage
  static Future<String?> uploadPdfReport({
    required Uint8List pdfBytes,
    required String fileName,
    String? topic,
  }) async {
    try {
      final userId = AuthService.getUserUid();
      if (userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      // Create reference with user-specific path
      final ref = _storage
          .ref()
          .child('reports')
          .child(userId)
          .child('${DateTime.now().millisecondsSinceEpoch}_$fileName');

      // Set metadata
      final metadata = SettableMetadata(
        contentType: 'application/pdf',
        customMetadata: {
          'userId': userId,
          'topic': topic ?? 'Unknown',
          'uploadDate': DateTime.now().toIso8601String(),
        },
      );

      // Upload file
      final uploadTask = ref.putData(pdfBytes, metadata);
      
      // Monitor upload progress (optional)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('Upload progress: ${progress.toStringAsFixed(1)}%');
      });

      // Wait for upload completion
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e, stackTrace) {
      // Log error to Crashlytics
      await _crashlytics.recordError(
        e,
        stackTrace,
        reason: 'PDF upload failed',
      );
      rethrow;
    }
  }

  /// Upload image file
  static Future<String?> uploadImage({
    required File imageFile,
    required String fileName,
  }) async {
    try {
      final userId = AuthService.getUserUid();
      if (userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      final ref = _storage
          .ref()
          .child('images')
          .child(userId)
          .child('${DateTime.now().millisecondsSinceEpoch}_$fileName');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'uploadDate': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = ref.putFile(imageFile, metadata);
      final snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e, stackTrace) {
      await _crashlytics.recordError(
        e,
        stackTrace,
        reason: 'Image upload failed',
      );
      rethrow;
    }
  }

  /// List user's uploaded files
  static Future<List<Reference>> listUserFiles() async {
    try {
      final userId = AuthService.getUserUid();
      if (userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      final reportsRef = _storage.ref().child('reports').child(userId);
      final result = await reportsRef.listAll();
      
      return result.items;
    } catch (e, stackTrace) {
      await _crashlytics.recordError(
        e,
        stackTrace,
        reason: 'List files failed',
      );
      return [];
    }
  }

  /// Delete file
  static Future<bool> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      return true;
    } catch (e, stackTrace) {
      await _crashlytics.recordError(
        e,
        stackTrace,
        reason: 'Delete file failed',
      );
      return false;
    }
  }

  /// Get file metadata
  static Future<FullMetadata?> getFileMetadata(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      return await ref.getMetadata();
    } catch (e, stackTrace) {
      await _crashlytics.recordError(
        e,
        stackTrace,
        reason: 'Get metadata failed',
      );
      return null;
    }
  }
}