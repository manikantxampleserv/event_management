import 'package:event_management/helpers/firebase_helpers.dart';
import 'package:flutter/material.dart';

class CachedAvatarWidget extends StatefulWidget {
  final String? photoUrl;
  final double width;
  final double height;
  final String fallbackLetter;

  const CachedAvatarWidget({
    super.key,
    this.photoUrl,
    required this.width,
    required this.height,
    required this.fallbackLetter,
  });

  @override
  State<CachedAvatarWidget> createState() => _CachedAvatarWidgetState();
}

class _CachedAvatarWidgetState extends State<CachedAvatarWidget> {
  String? _lastPhotoUrl;
  Widget? _cachedImage;

  @override
  Widget build(BuildContext context) {
    if (widget.photoUrl != _lastPhotoUrl) {
      _lastPhotoUrl = widget.photoUrl;
      _cachedImage = _buildImage();
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromARGB(255, 140, 158, 234),
      ),
      child: ClipOval(
        child: Stack(
          children: [
            Container(
              width: widget.width,
              height: widget.height,
              color: const Color(0xFF667eea),
              child: Center(
                child: Text(
                  widget.fallbackLetter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (_cachedImage != null) _cachedImage!,
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (widget.photoUrl == null || widget.photoUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    return buildProfileImage(
      widget.photoUrl,
      width: widget.width,
      height: widget.height,
    );
  }
}
