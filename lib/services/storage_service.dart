import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadProfileImage(String userId, File imageFile) async {
    try {
      print('Starting image upload for user: $userId');

      // Create a unique filename
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final String filePath = 'profile_images/$userId/$fileName';

      print('Upload path: $filePath');

      // Create reference to Firebase Storage
      final Reference ref = _storage.ref().child(filePath);

      // Upload file with metadata
      final UploadTask uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'userId': userId},
        ),
      );

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadURL = await snapshot.ref.getDownloadURL();

      print('Upload successful. URL: $downloadURL');
      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<bool> deleteProfileImage(String imageUrl) async {
    try {
      // Check if the URL is a valid Firebase Storage URL
      if (!_isFirebaseStorageUrl(imageUrl)) {
        print(
          'URL is not a Firebase Storage URL, skipping deletion: $imageUrl',
        );
        return true; // Return true since we don't need to delete external URLs
      }

      print('Deleting image: $imageUrl');
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print('Image deleted successfully');
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Helper method to check if URL is from Firebase Storage
  bool _isFirebaseStorageUrl(String url) {
    return url.contains('firebasestorage.googleapis.com') ||
        url.contains('storage.googleapis.com');
  }
}
