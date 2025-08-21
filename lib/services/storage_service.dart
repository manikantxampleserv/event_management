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
      print('Starting file upload: ${file.path}');

      if (!await file.exists()) {
        print('File does not exist: ${file.path}');
        return null;
      }

      final fileStats = await file.stat();
      print('File size: ${fileStats.size} bytes');

      if (fileStats.size > maxFileSizeBytes) {
        print(
          'File too large: ${fileStats.size} bytes (max: $maxFileSizeBytes)',
        );
        return null;
      }

      final bytes = await file.readAsBytes();
      print('File bytes read: ${bytes.length}');
      final base64String = base64Encode(bytes);
      print('Base64 encoded, length: ${base64String.length}');

      final fileName = file.path.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();
      print('File name: $fileName, Extension: $extension');

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
        print('Document set with ID: $documentId');
      } else {
        docRef = await _firestore.collection(collectionName).add(docData);
        print('Document added with auto-generated ID: ${docRef.id}');
      }

      final documentPath = '$collectionName/${docRef.id}';
      print('Upload successful, document path: $documentPath');
      return documentPath;
    } catch (e, stackTrace) {
      print('Error uploading file: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getFileFromFirestore({
    required String collectionName,
    required String documentId,
  }) async {
    try {
      print('Fetching document: $collectionName/$documentId');

      final doc = await _firestore
          .collection(collectionName)
          .doc(documentId)
          .get();

      if (!doc.exists) {
        print('Document does not exist: $collectionName/$documentId');
        return null;
      }

      final data = doc.data();
      print(
        'Document fetched successfully, has imageData: ${data?['imageData'] != null}',
      );

      return data;
    } catch (e, stackTrace) {
      print('Error fetching file: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<bool> deleteFileFromFirestore({
    required String collectionName,
    required String documentId,
  }) async {
    try {
      print('Deleting document: $collectionName/$documentId');

      await _firestore.collection(collectionName).doc(documentId).delete();
      print('Document deleted successfully');
      return true;
    } catch (e, stackTrace) {
      print('Error deleting file: $e');
      print('Stack trace: $stackTrace');
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
        print('Uploading file ${i + 1}/${files.length}: ${files[i].path}');

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
          print('File ${i + 1} uploaded successfully');
        } else {
          print('Failed to upload file ${i + 1}');
        }
      } catch (e) {
        print('Error uploading file ${i + 1}: $e');
      }
    }

    print(
      'Batch upload complete: ${uploadedPaths.length}/${files.length} files uploaded',
    );
    return uploadedPaths;
  }
}
