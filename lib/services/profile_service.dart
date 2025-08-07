import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/profile_model.dart';
import '../services/auth_service.dart';

class ProfileService extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Rx<ProfileModel?> profile = Rx<ProfileModel?>(null);
  final RxBool isLoading = false.obs;

  Future<void> fetchProfile(String userId) async {
    isLoading.value = true;
    print('Fetching profile for userId: $userId');

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      print('Document exists: ${doc.exists}');

      if (doc.exists) {
        print('Document data: ${doc.data()}');
        profile.value = ProfileModel.fromFirestore(doc);
      } else {
        print('No document found for userId: $userId - Creating new profile');

        // Get auth service to access user data
        final authService = Get.find<AuthService>();

        // Create new profile with auth data
        final newProfile = ProfileModel(
          id: userId,
          name: authService.user?.displayName ?? 'New User',
          email: authService.user?.email ?? '',
          photoUrl: authService.user?.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Create the profile in Firestore
        await createProfile(newProfile);
      }
    } catch (e) {
      print('Error fetching profile: $e');
      Get.snackbar(
        'Error',
        'Failed to load profile: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile(ProfileModel updatedProfile) async {
    try {
      await _firestore
          .collection('users')
          .doc(updatedProfile.id)
          .update(updatedProfile.toFirestore());
      profile.value = updatedProfile;

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      Get.snackbar(
        'Error',
        'Failed to update profile: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<bool> createProfile(ProfileModel profileModel) async {
    try {
      await _firestore
          .collection('users')
          .doc(profileModel.id)
          .set(profileModel.toFirestore());
      profile.value = profileModel;

      print('Profile created successfully for user: ${profileModel.id}');
      return true;
    } catch (e) {
      print('Error creating profile: $e');
      return false;
    }
  }

  Future<ProfileModel?> getProfileById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return ProfileModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting profile by id: $e');
      return null;
    }
  }

  // Method to create profile immediately after user signs up
  Future<void> createProfileOnSignUp(
    String userId,
    String email, {
    String? name,
    String? photoUrl,
  }) async {
    try {
      final newProfile = ProfileModel(
        id: userId,
        name: name ?? 'New User',
        email: email,
        photoUrl: photoUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await createProfile(newProfile);
    } catch (e) {
      print('Error creating profile on signup: $e');
    }
  }
}
