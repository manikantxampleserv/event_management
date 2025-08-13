import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

class StorageService extends GetxService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Track active upload tasks
  UploadTask? _currentUploadTask;
  final List<UploadTask> _activeTasks = [];

  /// Uploads a profile image and returns the download URL
  Future<String?> uploadProfileImage(String userId, File imageFile) async {
    if (!imageFile.existsSync()) {
      print('❌ Image file does not exist: ${imageFile.path}');
      return null;
    }

    try {
      print('StorageService: Starting upload for user: $userId');

      await _cancelCurrentUpload();

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = 'profile_images/${userId}_$timestamp.jpg';
      final storageRef = _storage.ref().child(filePath);

      final metadata = SettableMetadata(contentType: 'image/jpeg');

      _currentUploadTask = storageRef.putFile(imageFile, metadata);

      _currentUploadTask!.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
      });

      final snapshot = await _currentUploadTask!;
      _currentUploadTask = null;

      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('✅ Upload successful: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('❌ Firebase error: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('❌ General error: $e');
      return null;
    }
  }

  /// Retrieves the download URL for a stored image using its path
  Future<String?> getProfileImageUrl(String filePath) async {
    try {
      if (filePath.isEmpty) {
        print('StorageService: Empty file path provided');
        return null;
      }

      final ref = _storage.ref().child(filePath);

      // Check if file exists first
      try {
        await ref.getMetadata();
      } on FirebaseException catch (e) {
        if (e.code == 'object-not-found') {
          print('StorageService: File does not exist at path: $filePath');
          return null;
        }
      }

      final downloadUrl = await ref.getDownloadURL();
      print('StorageService: Successfully retrieved URL for: $filePath');
      return downloadUrl;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        print('StorageService: File does not exist');
        return null;
      }
      print(
        'StorageService: Error fetching image URL: ${e.code} - ${e.message}',
      );
      return null;
    } catch (e) {
      print('StorageService: General error fetching URL: $e');
      return null;
    }
  }

  /// Deletes a profile image using its download URL or file path
  Future<bool> deleteProfileImageByPath(String urlOrPath) async {
    try {
      if (urlOrPath.isEmpty) {
        print('StorageService: Empty URL or path provided for deletion');
        return false;
      }

      Reference ref;

      // Check if it's a download URL or a file path
      if (urlOrPath.startsWith('http')) {
        // It's a download URL, extract the path
        try {
          ref = _storage.refFromURL(urlOrPath);
        } catch (e) {
          print('StorageService: Invalid URL format: $urlOrPath');
          return false;
        }
      } else {
        // It's a file path
        ref = _storage.ref().child(urlOrPath);
      }

      print('StorageService: Attempting to delete: ${ref.fullPath}');

      // Check if file exists before attempting deletion
      try {
        await ref.getMetadata();
      } on FirebaseException catch (e) {
        if (e.code == 'object-not-found') {
          print('StorageService: File already deleted or does not exist');
          return true; // Consider success since the goal is achieved
        }
      }

      // Perform deletion with timeout
      await ref.delete().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('StorageService: Delete operation timeout');
          throw Exception('Delete timeout after 30 seconds');
        },
      );

      print('StorageService: Image deleted successfully');
      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        print('StorageService: File already deleted or does not exist');
        return true; // Consider success since the goal is achieved
      } else {
        print(
          'StorageService: Firebase delete error: ${e.code} - ${e.message}',
        );
        return false;
      }
    } catch (e) {
      print('StorageService: General delete error: $e');
      return false;
    }
  }

  /// Deletes multiple profile images
  Future<Map<String, bool>> deleteMultipleImages(
    List<String> urlsOrPaths,
  ) async {
    final results = <String, bool>{};

    for (final urlOrPath in urlsOrPaths) {
      try {
        final success = await deleteProfileImageByPath(urlOrPath);
        results[urlOrPath] = success;
      } catch (e) {
        print('StorageService: Error deleting $urlOrPath: $e');
        results[urlOrPath] = false;
      }
    }

    return results;
  }

  /// Cancels the current upload task
  Future<void> _cancelCurrentUpload() async {
    if (_currentUploadTask != null) {
      print('StorageService: Cancelling current upload');
      try {
        await _currentUploadTask!.cancel();
      } catch (e) {
        print('StorageService: Error cancelling upload: $e');
      }
      _activeTasks.remove(_currentUploadTask);
      _currentUploadTask = null;
    }
  }

  /// Cancels all active operations
  Future<void> cancelAllOperations() async {
    print('StorageService: Cancelling all active operations');

    // Cancel current upload
    await _cancelCurrentUpload();

    // Cancel all other active tasks
    for (final task in List<UploadTask>.from(_activeTasks)) {
      try {
        await task.cancel();
      } catch (e) {
        print('StorageService: Error cancelling task: $e');
      }
    }

    _activeTasks.clear();
    print('StorageService: All operations cancelled');
  }

  /// Cleanup failed upload references
  void cleanupFailedUpload() {
    if (_currentUploadTask != null) {
      _activeTasks.remove(_currentUploadTask);
      _currentUploadTask = null;
    }
  }

  /// Validates image file
  bool isValidImageFile(File file) {
    try {
      final extension = _getFileExtension(file.path).toLowerCase();
      const validExtensions = ['jpg', 'jpeg', 'png', 'webp'];
      return validExtensions.contains(extension);
    } catch (e) {
      print('StorageService: Error validating file: $e');
      return false;
    }
  }

  /// Checks if URL is a valid image URL
  bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    try {
      final uri = Uri.parse(url);
      return uri.hasAbsolutePath &&
          (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Gets file extension from path
  String _getFileExtension(String path) {
    final lastDot = path.lastIndexOf('.');
    if (lastDot == -1) return 'jpg'; // Default to jpg
    return path.substring(lastDot + 1).toLowerCase();
  }

  /// Gets content type based on file extension
  String getContentType(String extension) {
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

  /// Gets storage usage statistics
  Future<Map<String, dynamic>> getStorageStats(String userId) async {
    try {
      final userFolderRef = _storage.ref().child('profile_images/$userId');
      final listResult = await userFolderRef.listAll();

      int totalFiles = listResult.items.length;
      int totalSize = 0;

      for (final item in listResult.items) {
        try {
          final metadata = await item.getMetadata();
          totalSize += metadata.size ?? 0;
        } catch (e) {
          print('StorageService: Error getting metadata for ${item.name}: $e');
        }
      }

      return {
        'totalFiles': totalFiles,
        'totalSizeBytes': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      };
    } catch (e) {
      print('StorageService: Error getting storage stats: $e');
      return {'totalFiles': 0, 'totalSizeBytes': 0, 'totalSizeMB': '0.00'};
    }
  }

  /// Cleanup old profile images for a user (keeps only the latest N images)
  Future<bool> cleanupOldImages(String userId, {int keepLatest = 5}) async {
    try {
      final userFolderRef = _storage.ref().child('profile_images/$userId');
      final listResult = await userFolderRef.listAll();

      if (listResult.items.length <= keepLatest) {
        print(
          'StorageService: No cleanup needed. Current files: ${listResult.items.length}',
        );
        return true;
      }

      // Sort by creation time (extract timestamp from filename)
      final sortedItems = listResult.items.toList();
      sortedItems.sort((a, b) {
        final timestampA = _extractTimestampFromName(a.name);
        final timestampB = _extractTimestampFromName(b.name);
        return timestampB.compareTo(timestampA); // Newest first
      });

      // Delete old files
      final itemsToDelete = sortedItems.skip(keepLatest).toList();
      int deletedCount = 0;

      for (final item in itemsToDelete) {
        try {
          await item.delete();
          deletedCount++;
          print('StorageService: Deleted old image: ${item.name}');
        } catch (e) {
          print('StorageService: Error deleting ${item.name}: $e');
        }
      }

      print(
        'StorageService: Cleanup completed. Deleted $deletedCount old images',
      );
      return true;
    } catch (e) {
      print('StorageService: Error during cleanup: $e');
      return false;
    }
  }

  /// Extract timestamp from filename
  int _extractTimestampFromName(String filename) {
    try {
      final parts = filename.split('_');
      if (parts.length >= 2) {
        final timestampPart = parts[1].split('.')[0];
        return int.parse(timestampPart);
      }
    } catch (e) {
      print('StorageService: Error extracting timestamp from $filename: $e');
    }
    return 0;
  }

  @override
  void onClose() {
    cancelAllOperations();
    super.onClose();
  }
}
