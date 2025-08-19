import 'package:flutter/material.dart';

class CachedAvatarWidget extends StatefulWidget {
  final String? photoUrl;
  final double width;
  final double height;
  final String fallbackLetter;
  final VoidCallback? onImageUpdated;

  const CachedAvatarWidget({
    super.key,
    this.photoUrl,
    required this.width,
    required this.height,
    required this.fallbackLetter,
    this.onImageUpdated,
  });

  @override
  State<CachedAvatarWidget> createState() => _CachedAvatarWidgetState();
}

class _CachedAvatarWidgetState extends State<CachedAvatarWidget> {
  String? _lastPhotoUrl;
  Widget? _cachedImage;

  @override
  void initState() {
    super.initState();
    _lastPhotoUrl = widget.photoUrl;
    _cachedImage = _buildImage();
  }

  @override
  void didUpdateWidget(covariant CachedAvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.photoUrl != oldWidget.photoUrl) {
      _lastPhotoUrl = widget.photoUrl;
      _cachedImage = _buildImage();
      if (widget.onImageUpdated != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onImageUpdated!();
        });
      }
    }
  }

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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.width * 0.4,
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

    final cacheBustedUrl =
        '${widget.photoUrl}?v=${DateTime.now().millisecondsSinceEpoch}';

    return Image.network(
      cacheBustedUrl,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.cover,
      key: ValueKey(cacheBustedUrl),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: widget.width,
          height: widget.height,
          color: const Color(0xFF667eea),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return const SizedBox.shrink();
      },
    );
  }
}
