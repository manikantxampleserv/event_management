import 'dart:async';
import 'dart:io';

import 'package:event_management/authentication/login_screen.dart';
import 'package:event_management/helpers/firebase_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../models/profile_model.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService authService = Get.find<AuthService>();
  final ProfileService profileService = Get.put(ProfileService());
  final StorageService storageService = Get.put(StorageService());

  @override
  void initState() {
    super.initState();
    final userId = authService.user?.uid;

    if (userId != null) {
      profileService.fetchProfile(userId);

      // Force refresh after delay to ensure UI updates
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && profileService.profile.value?.photoUrl != null) {
          setState(() {}); // Force UI rebuild
        }
      });
    } else {
      Get.offAll(() => LoginScreen());
    }
  }

  // Helper method to force close all dialogs
  void _forceCloseAllDialogs() {
    if (Get.isDialogOpen == true) {
      Get.until((route) => !Get.isDialogOpen!);
    }
  }

  void _refreshProfile() async {
    final userId = authService.user?.uid;
    if (userId != null) {
      await profileService.fetchProfile(userId);
    }
  }

  // Image URL validation
  bool _isValidImageUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null &&
        uri.hasAbsolutePath &&
        (url.toLowerCase().endsWith('.jpg') ||
            url.toLowerCase().endsWith('.png') ||
            url.toLowerCase().endsWith('.jpeg') ||
            url.toLowerCase().endsWith('.webp') ||
            url.contains('firebasestorage.googleapis.com') ||
            url.contains('storage.googleapis.com'));
  }

  void _showPhotoOptions(ProfileModel profile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Update Profile Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _photoOptionButton(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () => _pickImage(ImageSource.camera, profile),
                ),
                _photoOptionButton(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () => _pickImage(ImageSource.gallery, profile),
                ),
                _photoOptionButton(
                  icon: Icons.link,
                  label: 'URL',
                  onTap: () => _showUrlDialog(profile),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (profile.photoUrl != null && profile.photoUrl!.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _removeProfilePhoto(profile),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Remove Photo',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _photoOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width / 4,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF667eea).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF667eea).withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF667eea), size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF667eea),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, ProfileModel profile) async {
    Navigator.pop(context);

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Show loading indicator
        Get.dialog(
          AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFF667eea)),
                const SizedBox(height: 16),
                const Text('Uploading image...'),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    Get.back();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
          barrierDismissible: false,
        );

        final userId = authService.user?.uid;
        if (userId == null) {
          _forceCloseAllDialogs();
          Get.snackbar(
            'Error',
            'User session expired. Please login again.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          Get.offAll(() => LoginScreen());
          return;
        }

        try {
          // Upload new image FIRST
          final imageDownloadUrl = await storageService.uploadFileToFirestore(
            collectionName: 'profile_images',
            file: File(pickedFile.path),
            documentId: userId,
          );

          if (imageDownloadUrl != null && imageDownloadUrl.isNotEmpty) {
            // Only delete old image AFTER successful upload
            if (profile.photoUrl != null &&
                profile.photoUrl!.isNotEmpty &&
                (profile.photoUrl!.contains('firebasestorage.googleapis.com') ||
                    profile.photoUrl!.contains('storage.googleapis.com'))) {
              // Try to delete old image, but don't let failure affect the process
              try {
                await storageService.deleteFileFromFirestore(
                  collectionName: 'profile_images',
                  documentId: userId,
                );
              } catch (deleteError) {
                // Continue even if delete fails
              }
            }

            _forceCloseAllDialogs();

            final updated = profile.copyWith(
              photoUrl: imageDownloadUrl,
              updatedAt: DateTime.now(),
            );

            final success = await profileService.updateProfile(updated);

            if (success) {
              setState(() {});
              Get.snackbar(
                'Success',
                'Profile image updated successfully',
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
                snackPosition: SnackPosition.TOP,
              );
            } else {
              Get.snackbar(
                'Error',
                'Failed to update profile',
                backgroundColor: Colors.red,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            }
          } else {
            _forceCloseAllDialogs();
            Get.snackbar(
              'Upload Failed',
              'Image upload failed. Please try again.',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
            );
          }
        } catch (uploadError) {
          _forceCloseAllDialogs();

          String errorMessage = 'Upload failed. Please try again.';
          if (uploadError.toString().contains('timeout')) {
            errorMessage =
                'Upload timeout. Please check your internet connection.';
          } else if (uploadError.toString().contains('cancelled')) {
            errorMessage = 'Upload was cancelled.';
            return; // Don't show error for user-cancelled operations
          } else if (uploadError.toString().contains('object-not-found')) {
            errorMessage = 'Upload failed. Please try again.';
          }

          Get.snackbar(
            'Error',
            errorMessage,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      }
    } catch (e) {
      _forceCloseAllDialogs();
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _removeProfilePhoto(ProfileModel profile) async {
    Navigator.pop(context);

    final bool? confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Remove Profile Photo'),
        content: const Text(
          'Are you sure you want to remove your profile photo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      Get.dialog(
        PopScope(
          onPopInvokedWithResult: (didPop, result) => Get.back(result: result),
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFF667eea)),
          ),
        ),
        barrierDismissible: false,
      );

      try {
        if (profile.photoUrl != null &&
            (profile.photoUrl!.contains('firebasestorage.googleapis.com') ||
                profile.photoUrl!.contains('storage.googleapis.com'))) {
          await storageService.deleteFileFromFirestore(
            collectionName: 'profile_images',
            documentId: profile.id.toString(),
          );
        }

        final updated = profile.copyWith(
          photoUrl: null,
          updatedAt: DateTime.now(),
        );

        final success = await profileService.updateProfile(updated);

        _forceCloseAllDialogs();

        if (success) {
          Get.snackbar(
            'Success',
            'Profile photo removed successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
            snackPosition: SnackPosition.TOP,
          );
        } else {
          Get.snackbar(
            'Error',
            'Failed to remove profile photo',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }
      } catch (e) {
        _forceCloseAllDialogs();
        Get.snackbar(
          'Error',
          'Failed to remove photo: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  void _showUrlDialog(ProfileModel profile) {
    Navigator.pop(context);
    final urlController = TextEditingController(text: profile.photoUrl ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: const Text('Photo URL'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: TextField(
            controller: urlController,
            decoration: const InputDecoration(
              hintText: 'Enter Image URL',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final url = urlController.text.trim();
              if (url.isNotEmpty) {
                if (!_isValidImageUrl(url)) {
                  Get.snackbar(
                    'Error',
                    'Please enter a valid image URL',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                final updated = profile.copyWith(
                  photoUrl: url,
                  updatedAt: DateTime.now(),
                );
                await profileService.updateProfile(updated);
              }
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showEditProfile(ProfileModel profile) {
    final nameController = TextEditingController(text: profile.name);
    final phoneController = TextEditingController(text: profile.phone ?? '');
    final bioController = TextEditingController(text: profile.bio ?? '');
    final photoUrlController = TextEditingController(
      text: profile.photoUrl ?? '',
    );
    bool isUpdating = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Profile Photo Section
                  Center(
                    child: GestureDetector(
                      onTap: () => _showPhotoOptions(profile),
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF667eea),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: buildProfileImage(
                                profile.photoUrl,
                                width: 94,
                                height: 94,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF667eea),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildTextField(
                    controller: nameController,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: photoUrlController,
                    label: 'Photo URL (Optional)',
                    icon: Icons.link,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: bioController,
                    label: 'Bio',
                    icon: Icons.edit_note,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isUpdating
                          ? null
                          : () async {
                              if (nameController.text.trim().isEmpty) {
                                Get.snackbar(
                                  'Error',
                                  'Name cannot be empty',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              setState(() => isUpdating = true);

                              final updated = profile.copyWith(
                                name: nameController.text.trim(),
                                phone: phoneController.text.trim(),
                                bio: bioController.text.trim(),
                                photoUrl: photoUrlController.text.trim().isEmpty
                                    ? null
                                    : photoUrlController.text.trim(),
                                updatedAt: DateTime.now(),
                              );

                              final success = await profileService
                                  .updateProfile(updated);
                              setState(() => isUpdating = false);

                              if (success) {
                                Get.back();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667eea),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isUpdating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF667eea)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          labelStyle: TextStyle(color: Colors.grey[600]),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF667eea), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildActionButton(
            icon: Icons.settings,
            title: 'Settings',
            subtitle: 'App preferences and configurations',
            onTap: () {
              Get.snackbar(
                'Info',
                'Settings screen will be implemented',
                backgroundColor: Colors.blue,
                colorText: Colors.white,
              );
            },
          ),
          const Divider(height: 1),
          _buildActionButton(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () {
              Get.snackbar(
                'Info',
                'Help & Support screen will be implemented',
                backgroundColor: Colors.blue,
                colorText: Colors.white,
              );
            },
          ),
          const Divider(height: 1),
          _buildActionButton(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: () {
              Get.snackbar(
                'Info',
                'Privacy Policy screen will be implemented',
                backgroundColor: Colors.blue,
                colorText: Colors.white,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF667eea), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.red[200]!),
      ),
      child: TextButton.icon(
        onPressed: () async {
          final bool? confirm = await Get.dialog<bool>(
            AlertDialog(
              title: const Text('Sign Out'),
              content: const Text('Are you sure you want to sign out?'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Get.back(result: true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          );

          if (confirm == true) {
            try {
              await authService.signOut();
              Get.offAll(() => LoginScreen());
            } catch (e) {
              Get.snackbar(
                'Error',
                'Failed to sign out: $e',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          }
        },
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text(
          'Sign Out',
          style: TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        // Refresh button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                            onPressed: _refreshProfile,
                            tooltip: 'Refresh Profile',
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Edit button
                        Obx(() {
                          final profile = profileService.profile.value;
                          if (profile == null) return const SizedBox();
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: () => _showEditProfile(profile),
                              tooltip: 'Edit Profile',
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Obx(() {
                    if (profileService.isLoading.value) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Color(0xFF667eea)),
                            SizedBox(height: 16),
                            Text(
                              'Loading profile...',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final profile = profileService.profile.value;
                    if (profile == null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 80,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Profile Setup',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Setting up your profile...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _refreshProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF667eea),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Profile Picture Section
                          GestureDetector(
                            onTap: () => _showPhotoOptions(profile),
                            child: Stack(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF667eea),
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: buildProfileImage(
                                      profile.photoUrl,
                                      width: 94,
                                      height: 94,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF667eea),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 5,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          Text(
                            profile.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            profile.email,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 32),

                          if (profile.phone != null &&
                              profile.phone!.isNotEmpty)
                            _buildInfoCard(
                              icon: Icons.phone,
                              title: 'Phone',
                              value: profile.phone!,
                            ),

                          if (profile.bio != null && profile.bio!.isNotEmpty)
                            _buildInfoCard(
                              icon: Icons.edit_note,
                              title: 'Bio',
                              value: profile.bio!,
                            ),
                          _buildInfoCard(
                            icon: Icons.calendar_today,
                            title: 'Member Since',
                            value:
                                '${profile.createdAt.day}/${profile.createdAt.month}/${profile.createdAt.year}',
                          ),
                          const SizedBox(height: 32),
                          _buildActionButtons(),
                          const SizedBox(height: 16),
                          _buildSignOutButton(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
