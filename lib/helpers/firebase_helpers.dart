import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_management/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final Map<String, Widget> _imageCache = {};

Widget buildProfileImage(
  String? photoUrlOrPath, {
  double? width,
  double? height,
}) {
  final cacheKey = '${photoUrlOrPath}_${width}_$height';

  if (_imageCache.containsKey(cacheKey)) {
    return _imageCache[cacheKey]!;
  }

  if (photoUrlOrPath == null || photoUrlOrPath.isEmpty) {
    final widget = Container(
      width: width ?? 112,
      height: height ?? 112,
      color: Colors.grey[100],
      child: const Icon(Icons.person, size: 60, color: Color(0xFF667eea)),
    );
    _imageCache[cacheKey] = widget;
    return widget;
  }

  Widget imageWidget;

  if (photoUrlOrPath.startsWith('http')) {
    imageWidget = CachedNetworkImage(
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
    imageWidget = FutureBuilder<Map<String, dynamic>?>(
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
          final memoryImage = Image.memory(
            bytes,
            width: width ?? 112,
            height: height ?? 112,
            fit: BoxFit.cover,
          );

          _imageCache[cacheKey] = memoryImage;
          return memoryImage;
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

  if (photoUrlOrPath.startsWith('http')) {
    _imageCache[cacheKey] = imageWidget;
  }

  return imageWidget;
}

void clearImageCache() {
  _imageCache.clear();
}

Future<Map<String, dynamic>?> _getImageFromFirestore(
  String documentPath,
) async {
  try {
    final parts = documentPath.split('/');
    if (parts.length >= 2) {
      final collectionName = parts[0];
      final documentId = parts[1];
      final firestoreService = Get.find<StorageService>();
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
