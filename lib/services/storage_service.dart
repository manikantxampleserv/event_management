import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class StorageService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const int maxFileSizeBytes = 500000;

  Future<String?> uploadFileToFirestore({
    required String collectionName,
    required File file,
    String? documentId,
    Map<String, dynamic>? additionalMetadata,
  }) async {
    try {
      if (!await file.exists()) {
        return null;
      }

      final fileStats = await file.stat();

      if (fileStats.size > maxFileSizeBytes) {
        return null;
      }

      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);

      final fileName = file.path.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();

      final docData = {
        'fileName': fileName,
        'fileSize': fileStats.size,
        'contentType': _getContentType(extension),
        'imageData': base64String,
        'uploadedAt': FieldValue.serverTimestamp(),
        'userId': documentId ?? 'unknown',
        ...?additionalMetadata,
      };

      DocumentReference docRef;
      if (documentId != null) {
        docRef = _firestore.collection(collectionName).doc(documentId);
        await docRef.set(docData);
      } else {
        docRef = await _firestore.collection(collectionName).add(docData);
      }

      final documentPath = '$collectionName/${docRef.id}';
      return documentPath;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getFileFromFirestore({
    required String collectionName,
    required String documentId,
  }) async {
    try {
      final doc = await _firestore
          .collection(collectionName)
          .doc(documentId)
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data();
      return data;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteFileFromFirestore({
    required String collectionName,
    required String documentId,
  }) async {
    try {
      await _firestore.collection(collectionName).doc(documentId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      default:
        return 'image/jpeg';
    }
  }

  bool isSupportedImageFormat(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp'].contains(extension);
  }

  String getFileSizeString(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  Future<List<String>> uploadMultipleFiles({
    required String collectionName,
    required List<File> files,
    Map<String, dynamic>? additionalMetadata,
  }) async {
    List<String> uploadedPaths = [];

    for (int i = 0; i < files.length; i++) {
      try {
        String? path = await uploadFileToFirestore(
          collectionName: collectionName,
          file: files[i],
          additionalMetadata: {
            'batchIndex': i,
            'totalFiles': files.length,
            ...?additionalMetadata,
          },
        );

        if (path != null) {
          uploadedPaths.add(path);
        }
      } catch (e) {
        return [];
      }
    }

    return uploadedPaths;
  }
}
