import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_management/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildProfileImage(
  String? photoUrlOrPath, {
  double? width,
  double? height,
}) {
  if (photoUrlOrPath == null || photoUrlOrPath.isEmpty) {
    return Container(
      width: width ?? 112,
      height: height ?? 112,
      color: Colors.grey[100],
      child: const Icon(Icons.person, size: 60, color: Color(0xFF667eea)),
    );
  }

  // Check if it's a URL or Firestore path
  if (photoUrlOrPath.startsWith('http')) {
    // It's a regular URL - use CachedNetworkImage
    return CachedNetworkImage(
      imageUrl: photoUrlOrPath,
      width: width ?? 112,
      height: height ?? 112,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[100],
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF667eea),
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[100],
        child: const Icon(Icons.person, size: 60, color: Color(0xFF667eea)),
      ),
    );
  } else {
    // It's a Firestore document path - fetch Base64 data
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getImageFromFirestore(photoUrlOrPath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: width ?? 112,
            height: height ?? 112,
            color: Colors.grey[100],
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF667eea),
                strokeWidth: 2,
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Container(
            width: width ?? 112,
            height: height ?? 112,
            color: Colors.grey[100],
            child: const Icon(Icons.person, size: 60, color: Color(0xFF667eea)),
          );
        }

        final imageData = snapshot.data!['imageData'] as String?;
        if (imageData == null) {
          return Container(
            width: width ?? 112,
            height: height ?? 112,
            color: Colors.grey[100],
            child: const Icon(Icons.person, size: 60, color: Color(0xFF667eea)),
          );
        }

        try {
          final bytes = base64Decode(imageData);
          return Image.memory(
            bytes,
            width: width ?? 112,
            height: height ?? 112,
            fit: BoxFit.cover,
          );
        } catch (e) {
          print('Error decoding Base64 image: $e');
          return Container(
            width: width ?? 112,
            height: height ?? 112,
            color: Colors.grey[100],
            child: const Icon(Icons.person, size: 60, color: Color(0xFF667eea)),
          );
        }
      },
    );
  }
}

// Add this helper method to fetch image data from Firestore
Future<Map<String, dynamic>?> _getImageFromFirestore(
  String documentPath,
) async {
  try {
    // Assuming you have a FirestoreFileService instance
    final parts = documentPath.split('/');
    if (parts.length >= 2) {
      final collectionName = parts[0];
      final documentId = parts[1];

      // You'll need to get your FirestoreFileService instance
      final firestoreService =
          Get.find<StorageService>(); // Or however you access it
      return await firestoreService.getFileFromFirestore(
        collectionName: collectionName,
        documentId: documentId,
      );
    }
  } catch (e) {
    print('Error fetching image from Firestore: $e');
  }
  return null;
}
