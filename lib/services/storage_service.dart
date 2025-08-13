import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class StorageService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> uploadFileToFirestore({
    required String collectionName,
    required File file,
    String? documentId,
    Map<String, dynamic>? additionalMetadata,
  }) async {
    try {
      final fileStats = await file.stat();
      if (fileStats.size > 500000) {
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

      return doc.data();
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
      default:
        return 'image/jpeg';
    }
  }
}
