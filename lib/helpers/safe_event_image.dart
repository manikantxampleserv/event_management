import 'dart:convert';
import 'dart:typed_data';
import 'package:event_management/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:event_management/services/storage_service.dart';

class SafeEventImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const SafeEventImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.isEmpty) {
      return _buildErrorWidget();
    }

    Widget imageWidget = FutureBuilder<Widget>(
      future: _loadImage(),
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

    if (borderRadius != null) {
      imageWidget = ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return SizedBox(width: width, height: height, child: imageWidget);
  }

  Future<Widget> _loadImage() async {
    try {
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
      print('Error in _loadImage: $e');
      rethrow;
    }
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
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

extension EventModelImageExtension on EventModel {
  Widget buildThumbnailImage({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    return SafeEventImage(
      imagePath: displayImage,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
    );
  }

  Widget buildEventImage(
    int index, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
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
        // Using SafeEventImage directly
        SafeEventImage(
          imagePath: event.thumbnail,
          width: 200,
          height: 150,
          borderRadius: BorderRadius.circular(12),
        ),

        const SizedBox(height: 16),

        // Using extension method
        event.buildThumbnailImage(
          width: 200,
          height: 150,
          borderRadius: BorderRadius.circular(12),
        ),

        const SizedBox(height: 16),

        // Event images gallery
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
