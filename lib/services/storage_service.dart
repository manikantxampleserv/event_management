import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseFirestore _firestore;

  StorageService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String?> uploadProfileImage(String userId, File imageFile) async {
    if (userId.isEmpty) {
      if (kDebugMode) {
        print('StorageService: User ID is empty. Cannot upload profile image.');
      }
      return null;
    }

    try {
      if (!await imageFile.exists()) {
        if (kDebugMode) {
          print('StorageService: Image file does not exist: ${imageFile.path}');
        }
        return null;
      }
    } catch (e, st) {
      if (kDebugMode) {
        print('StorageService: Error checking file existence: $e');
        print('StorageService: Stacktrace for file existence check: $st');
      }
      return null;
    }

    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();

      if (imageBytes.lengthInBytes > 1048576) {
        if (kDebugMode) {
          print(
            'StorageService: Image file too large (${imageBytes.lengthInBytes} bytes). Max size is 1MB.',
          );
        }
        return null;
      }

      final String base64Image = base64Encode(imageBytes);
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basenameWithoutExtension(imageFile.path)}';

      final String contentType = _inferContentTypeFromPath(imageFile.path);

      if (kDebugMode) {
        print(
          'StorageService: Storing image for user: $userId, size: ${imageBytes.lengthInBytes} bytes',
        );
      }

      final Map<String, dynamic> imageData = {
        'userId': userId,
        'fileName': fileName,
        'contentType': contentType,
        'imageData': base64Image,
        'uploadedAt': FieldValue.serverTimestamp(),
        'fileSize': imageBytes.lengthInBytes,
        'originalPath': imageFile.path,
      };

      final DocumentReference docRef = await _firestore
          .collection('profile_images')
          .add(imageData);

      final String documentId = docRef.id;

      if (kDebugMode) {
        print('StorageService: Upload successful. Document ID: $documentId');
      }

      return documentId;
    } on FirebaseException catch (e, st) {
      if (kDebugMode) {
        print(
          'StorageService: FirebaseException during upload: ${e.code} ${e.message}',
        );
        print('StorageService: FirebaseException stacktrace: $st');
      }

      switch (e.code) {
        case 'permission-denied':
          if (kDebugMode) {
            print('StorageService: Permission denied. Check Firestore rules.');
          }
          break;
        case 'unavailable':
          if (kDebugMode) print('StorageService: Service unavailable.');
          break;
        case 'resource-exhausted':
          if (kDebugMode) print('StorageService: Quota exceeded.');
          break;
        default:
          if (kDebugMode) {
            print('StorageService: Unhandled Firestore error: ${e.code}');
          }
      }
      return null;
    } catch (e, st) {
      if (kDebugMode) {
        print('StorageService: Generic error uploading image: $e');
        print('StorageService: Generic error stacktrace: $st');
      }
      return null;
    }
  }

  Future<Uint8List?> getImageData(String documentId) async {
    if (documentId.isEmpty) {
      if (kDebugMode) {
        print('StorageService: Document ID is empty.');
      }
      return null;
    }

    try {
      final DocumentSnapshot doc = await _firestore
          .collection('profile_images')
          .doc(documentId)
          .get();

      if (!doc.exists) {
        if (kDebugMode) {
          print('StorageService: Document not found: $documentId');
        }
        return null;
      }

      final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data == null || !data.containsKey('imageData')) {
        if (kDebugMode) {
          print('StorageService: No image data found in document: $documentId');
        }
        return null;
      }

      final String base64Image = data['imageData'] as String;
      return base64Decode(base64Image);
    } on FirebaseException catch (e, st) {
      if (kDebugMode) {
        print(
          'StorageService: FirebaseException retrieving image $documentId: ${e.code} ${e.message}',
        );
        print('StorageService: FirebaseException stacktrace: $st');
      }
      return null;
    } catch (e, st) {
      if (kDebugMode) {
        print('StorageService: Generic error retrieving image $documentId: $e');
        print('StorageService: Generic error stacktrace: $st');
      }
      return null;
    }
  }

  // Method to get image metadata
  Future<Map<String, dynamic>?> getImageMetadata(String documentId) async {
    if (documentId.isEmpty) {
      if (kDebugMode) {
        print('StorageService: Document ID is empty.');
      }
      return null;
    }

    try {
      final DocumentSnapshot doc = await _firestore
          .collection('profile_images')
          .doc(documentId)
          .get();

      if (!doc.exists) {
        if (kDebugMode) {
          print('StorageService: Document not found: $documentId');
        }
        return null;
      }

      final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data == null) return null;

      // Return metadata without the actual image data
      return {
        'userId': data['userId'],
        'fileName': data['fileName'],
        'contentType': data['contentType'],
        'uploadedAt': data['uploadedAt'],
        'fileSize': data['fileSize'],
        'originalPath': data['originalPath'],
      };
    } catch (e, st) {
      if (kDebugMode) {
        print('StorageService: Error retrieving metadata $documentId: $e');
        print('StorageService: Stacktrace: $st');
      }
      return null;
    }
  }

  Future<bool> deleteProfileImage(String? documentId) async {
    if (documentId == null || documentId.isEmpty) {
      if (kDebugMode) {
        print(
          'StorageService: Document ID is null or empty. Nothing to delete.',
        );
      }
      return false;
    }

    if (kDebugMode) {
      print('StorageService: Deleting image document: $documentId');
    }

    try {
      await _firestore.collection('profile_images').doc(documentId).delete();

      if (kDebugMode) {
        print(
          'StorageService: Image document deleted successfully: $documentId',
        );
      }
      return true;
    } on FirebaseException catch (e, st) {
      if (kDebugMode) {
        print(
          'StorageService: FirebaseException deleting document $documentId: ${e.code} ${e.message}',
        );
        print('StorageService: FirebaseException stacktrace: $st');
      }

      if (e.code == 'not-found') {
        if (kDebugMode) {
          print(
            'StorageService: Document not found (already deleted): $documentId',
          );
        }
        return true;
      }
      return false;
    } catch (e, st) {
      if (kDebugMode) {
        print(
          'StorageService: Generic error deleting document $documentId: $e',
        );
        print('StorageService: Generic error stacktrace: $st');
      }
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getUserProfileImages(String userId) async {
    if (userId.isEmpty) {
      if (kDebugMode) {
        print('StorageService: User ID is empty.');
      }
      return [];
    }

    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('profile_images')
          .where('userId', isEqualTo: userId)
          .orderBy('uploadedAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'documentId': doc.id,
          'userId': data['userId'],
          'fileName': data['fileName'],
          'contentType': data['contentType'],
          'uploadedAt': data['uploadedAt'],
          'fileSize': data['fileSize'],
          'originalPath': data['originalPath'],
        };
      }).toList();
    } catch (e, st) {
      if (kDebugMode) {
        print('StorageService: Error getting user images for $userId: $e');
        print('StorageService: Stacktrace: $st');
      }
      return [];
    }
  }

  // Helpers
  String _inferContentTypeFromPath(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.heic':
      case '.heif':
        return 'image/heif'; // Common on Apple devices
      default:
        return 'application/octet-stream';
    }
  }
}
