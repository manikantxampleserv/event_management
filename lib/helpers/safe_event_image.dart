import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_management/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:event_management/services/storage_service.dart';

final Map<String, Uint8List> _imageDataCache = {};
final Map<String, int> _cacheTimestamps = {};

class SafeEventImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final bool forceRefresh;

  const SafeEventImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.forceRefresh = false,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.isEmpty) {
      return _buildErrorWidget();
    }

    Widget imageWidget;

    if (imagePath.startsWith('http')) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final cacheBustedUrl = imagePath.contains('?')
          ? '$imagePath&t=$now'
          : '$imagePath?t=$now';

      imageWidget = CachedNetworkImage(
        imageUrl: forceRefresh ? cacheBustedUrl : imagePath,
        width: width,
        height: height,
        fit: fit,
        key: forceRefresh ? ValueKey('${cacheBustedUrl}_$now') : null,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildErrorWidget(),
        memCacheWidth: width?.toInt(),
        memCacheHeight: height?.toInt(),
      );
    } else {
      imageWidget = FutureBuilder<Widget>(
        future: _loadImageFromFirestore(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildPlaceholder();
          }

          if (snapshot.hasError) {
            print('Error loading image: ${snapshot.error}');
            return _buildErrorWidget();
          }

          return snapshot.data ?? _buildErrorWidget();
        },
      );
    }

    if (borderRadius != null) {
      imageWidget = ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return SizedBox(width: width, height: height, child: imageWidget);
  }

  Future<Widget> _loadImageFromFirestore() async {
    try {
      final cacheKey = imagePath;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (forceRefresh ||
          (_cacheTimestamps.containsKey(cacheKey) &&
              now - _cacheTimestamps[cacheKey]! > 300000)) {
        _imageDataCache.remove(cacheKey);
        _cacheTimestamps.remove(cacheKey);
      }

      if (_imageDataCache.containsKey(cacheKey)) {
        return Image.memory(
          _imageDataCache[cacheKey]!,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            print('Error displaying cached memory image: $error');
            return _buildErrorWidget();
          },
        );
      }

      final pathParts = imagePath.split('/');
      if (pathParts.length != 2) {
        throw Exception('Invalid image path format: $imagePath');
      }

      final storageService = Get.find<StorageService>();
      final doc = await storageService.getFileFromFirestore(
        collectionName: pathParts[0],
        documentId: pathParts[1],
      );

      if (doc != null && doc['imageData'] != null) {
        try {
          Uint8List bytes = base64Decode(doc['imageData']);

          _imageDataCache[cacheKey] = bytes;
          _cacheTimestamps[cacheKey] = now;

          return Image.memory(
            bytes,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              print('Error displaying memory image: $error');
              return _buildErrorWidget();
            },
          );
        } catch (e) {
          throw Exception('Failed to decode image data: $e');
        }
      } else {
        throw Exception('Image document not found or no image data');
      }
    } catch (e) {
      print('Error in _loadImageFromFirestore: $e');
      rethrow;
    }
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF667eea),
              strokeWidth: 2,
            ),
          ),
        );
  }

  Widget _buildErrorWidget() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[100],
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
          ),
        );
  }
}

void clearEventImageCache() {
  _imageDataCache.clear();
  _cacheTimestamps.clear();
}

void clearEventImageCacheForPath(String? imagePath) {
  if (imagePath == null) return;
  _imageDataCache.remove(imagePath);
  _cacheTimestamps.remove(imagePath);
}

void refreshEventImage(String? imagePath) {
  clearEventImageCacheForPath(imagePath);
}

extension EventModelImageExtension on EventModel {
  Widget buildThumbnailImage({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    bool forceRefresh = false,
  }) {
    return SafeEventImage(
      imagePath: displayImage,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      forceRefresh: forceRefresh,
    );
  }

  Widget buildEventImage(
    int index, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    bool forceRefresh = false,
  }) {
    if (index < 0 || index >= eventImages.length) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported),
      );
    }

    return SafeEventImage(
      imagePath: eventImages[index],
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      forceRefresh: forceRefresh,
    );
  }
}

class EventImageExamples extends StatelessWidget {
  final EventModel event;

  const EventImageExamples({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SafeEventImage(
          imagePath: event.thumbnail,
          width: 200,
          height: 150,
          borderRadius: BorderRadius.circular(12),
        ),

        const SizedBox(height: 16),

        event.buildThumbnailImage(
          width: 200,
          height: 150,
          borderRadius: BorderRadius.circular(12),
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: event.eventImages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: event.buildEventImage(
                  index,
                  width: 100,
                  height: 100,
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
