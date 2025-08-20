import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_management/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final Map<String, Widget> _imageCache = {};
final Map<String, int> _cacheTimestamps = {};

Widget buildProfileImage(
  String? photoUrlOrPath, {
  double? width,
  double? height,
  bool forceRefresh = false,
}) {
  final cacheKey = '${photoUrlOrPath}_${width}_$height';
  final now = DateTime.now().millisecondsSinceEpoch;

  if (forceRefresh ||
      (!photoUrlOrPath.toString().startsWith('http') &&
          _cacheTimestamps.containsKey(cacheKey) &&
          now - _cacheTimestamps[cacheKey]! > 30000)) {
    _imageCache.remove(cacheKey);
    _cacheTimestamps.remove(cacheKey);
  }

  if (photoUrlOrPath != null && photoUrlOrPath.isNotEmpty) {
    final existingKeys = _imageCache.keys
        .where((key) => key.startsWith('${photoUrlOrPath}_'))
        .toList();
    for (final key in existingKeys) {
      if (key != cacheKey) {
        _imageCache.remove(key);
        _cacheTimestamps.remove(key);
      }
    }
  }

  if (_imageCache.containsKey(cacheKey) && !forceRefresh) {
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
    _cacheTimestamps[cacheKey] = now;
    return widget;
  }

  Widget imageWidget;

  if (photoUrlOrPath.startsWith('http')) {
    final cacheBustedUrl = photoUrlOrPath.contains('?')
        ? '$photoUrlOrPath&t=$now'
        : '$photoUrlOrPath?t=$now';

    imageWidget = CachedNetworkImage(
      imageUrl: cacheBustedUrl,
      width: width ?? 112,
      height: height ?? 112,
      fit: BoxFit.cover,
      key: ValueKey('${cacheBustedUrl}_$now'),
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
      key: ValueKey('${photoUrlOrPath}_$now'),
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
            key: ValueKey('memory_${photoUrlOrPath}_$now'),
          );

          _imageCache[cacheKey] = memoryImage;
          _cacheTimestamps[cacheKey] = now;

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
    _cacheTimestamps[cacheKey] = now;
  }

  return imageWidget;
}

void clearImageCache() {
  _imageCache.clear();
  _cacheTimestamps.clear();
}

void clearImageCacheForUrl(String? photoUrl) {
  if (photoUrl == null) return;

  final keysToRemove = _imageCache.keys
      .where((key) => key.startsWith('${photoUrl}_'))
      .toList();

  for (final key in keysToRemove) {
    _imageCache.remove(key);
    _cacheTimestamps.remove(key);
  }
}

void refreshImage(String? photoUrl) {
  clearImageCacheForUrl(photoUrl);
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
