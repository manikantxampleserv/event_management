import 'package:event_management/authentication/login_screen.dart';
import 'package:event_management/helpers/firebase_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/profile_model.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';

// Theme Controller for managing dark/light mode
class ThemeController extends GetxController {
  var isDarkMode = false.obs;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    update();
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize with system theme
    isDarkMode.value = Get.isPlatformDarkMode;
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ThemeController themeController = Get.put(ThemeController());
  final AuthService authService = Get.find<AuthService>();
  final ProfileService profileService = Get.find<ProfileService>();

  bool _notificationsEnabled = true;
  bool _emailNotifications = false;
  bool _pushNotifications = true;
  bool _locationServices = true;

  @override
  void initState() {
    super.initState();
    final userId = authService.user?.uid;
    if (userId != null && profileService.profile.value == null) {
      profileService.fetchProfile(userId);
    }
  }

  void _refreshProfile() async {
    final userId = authService.user?.uid;
    if (userId != null) {
      await profileService.fetchProfile(userId);
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text('About App'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Event Management App',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667eea),
                ),
              ),
              SizedBox(height: 8),
              Text('Version: 1.0.0'),
              SizedBox(height: 4),
              Text('Build: 2025.1.0'),
              SizedBox(height: 12),
              Text(
                'A comprehensive event management application built with Flutter.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFF667eea)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Sign Out'),
          content: const Text(
            'Are you sure you want to sign out from your account?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
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
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
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
              // Custom App Bar with Profile Integration
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: _refreshProfile,
                        tooltip: 'Refresh',
                      ),
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
                              'Loading settings...',
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

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Profile Header Section
                          if (profile != null) _buildProfileHeader(profile),

                          const SizedBox(height: 32),

                          // App Settings Section
                          _buildSectionCard(
                            title: 'App Settings',
                            children: [
                              // Dark Mode Toggle
                              Obx(
                                () => _buildSettingsTile(
                                  icon: themeController.isDarkMode.value
                                      ? Icons.dark_mode
                                      : Icons.light_mode,
                                  title: 'Dark Mode',
                                  subtitle: themeController.isDarkMode.value
                                      ? 'Dark theme enabled'
                                      : 'Light theme enabled',
                                  trailing: Switch(
                                    value: themeController.isDarkMode.value,
                                    onChanged: (value) {
                                      themeController.toggleTheme();
                                    },
                                    activeColor: const Color(0xFF667eea),
                                  ),
                                  isFirst: true,
                                ),
                              ),

                              const Divider(height: 1),

                              _buildSettingsTile(
                                icon: Icons.notifications_outlined,
                                title: 'Notifications',
                                subtitle: 'Manage notification preferences',
                                trailing: Switch(
                                  value: _notificationsEnabled,
                                  onChanged: (value) {
                                    setState(() {
                                      _notificationsEnabled = value;
                                    });
                                  },
                                  activeColor: const Color(0xFF667eea),
                                ),
                              ),

                              const Divider(height: 1),

                              _buildSettingsTile(
                                icon: Icons.language_outlined,
                                title: 'Language',
                                subtitle: 'English (US)',
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: () {
                                  Get.snackbar(
                                    'Info',
                                    'Language selection coming soon',
                                    backgroundColor: const Color(0xFF667eea),
                                    colorText: Colors.white,
                                  );
                                },
                                isLast: true,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Privacy & Security Section
                          _buildSectionCard(
                            title: 'Privacy & Security',
                            children: [
                              _buildSettingsTile(
                                icon: Icons.email_outlined,
                                title: 'Email Notifications',
                                subtitle: 'Receive updates via email',
                                trailing: Switch(
                                  value: _emailNotifications,
                                  onChanged: (value) {
                                    setState(() {
                                      _emailNotifications = value;
                                    });
                                  },
                                  activeColor: const Color(0xFF667eea),
                                ),
                                isFirst: true,
                              ),

                              const Divider(height: 1),

                              _buildSettingsTile(
                                icon: Icons.push_pin_outlined,
                                title: 'Push Notifications',
                                subtitle: 'Receive push notifications',
                                trailing: Switch(
                                  value: _pushNotifications,
                                  onChanged: (value) {
                                    setState(() {
                                      _pushNotifications = value;
                                    });
                                  },
                                  activeColor: const Color(0xFF667eea),
                                ),
                              ),

                              const Divider(height: 1),

                              _buildSettingsTile(
                                icon: Icons.location_on_outlined,
                                title: 'Location Services',
                                subtitle: 'Allow location access for events',
                                trailing: Switch(
                                  value: _locationServices,
                                  onChanged: (value) {
                                    setState(() {
                                      _locationServices = value;
                                    });
                                  },
                                  activeColor: const Color(0xFF667eea),
                                ),
                              ),

                              const Divider(height: 1),

                              _buildSettingsTile(
                                icon: Icons.security_outlined,
                                title: 'Privacy Policy',
                                subtitle: 'Read our privacy policy',
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: () {},
                                isLast: true,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Support & Help Section
                          _buildSectionCard(
                            title: 'Support & Help',
                            children: [
                              _buildSettingsTile(
                                icon: Icons.help_outline,
                                title: 'Help Center',
                                subtitle: 'Get help and support',
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: () {},
                                isFirst: true,
                              ),

                              const Divider(height: 1),

                              _buildSettingsTile(
                                icon: Icons.feedback_outlined,
                                title: 'Send Feedback',
                                subtitle: 'Help us improve the app',
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: () {},
                              ),

                              const Divider(height: 1),

                              _buildSettingsTile(
                                icon: Icons.star_outline,
                                title: 'Rate App',
                                subtitle: 'Rate us on the app store',
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: () {},
                              ),

                              const Divider(height: 1),

                              _buildSettingsTile(
                                icon: Icons.info_outline,
                                title: 'About',
                                subtitle: 'App version and information',
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: _showAboutDialog,
                                isLast: true,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Sign Out Button
                          _buildSignOutButton(),

                          const SizedBox(height: 40),

                          // App Version
                          Center(
                            child: Text(
                              'Event Management App v1.0.0',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
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

  Widget _buildProfileHeader(ProfileModel profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: buildProfileImage(profile.photoUrl, width: 64, height: 64),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
                if (profile.phone != null && profile.phone!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    profile.phone!,
                    style: const TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                ],
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                Get.back(); // Go back to profile to edit
              },
              icon: const Icon(Icons.edit, color: Colors.white, size: 20),
              tooltip: 'Edit Profile',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF667eea),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
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
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (textColor ?? const Color(0xFF667eea)).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: textColor ?? const Color(0xFF667eea),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor ?? Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
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
        onPressed: _showLogoutConfirmation,
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text(
          'Sign Out',
          style: TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
