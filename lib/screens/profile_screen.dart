import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  final AuthService authService = Get.find<AuthService>();

  @override
  Widget build(BuildContext context) {
    final user = authService.user;
    final isGuest = authService.isGuest;
    final displayName = user?.displayName ?? 'Guest';
    final email = user?.email ?? 'Not signed in';
    final photoUrl = user?.photoURL;
    final provider = user?.providerData.isNotEmpty == true
        ? user!.providerData[0].providerId
        : 'guest';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
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
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: photoUrl != null
                    ? NetworkImage(photoUrl)
                    : null,
                child: photoUrl == null
                    ? const Icon(
                        Icons.person,
                        size: 60,
                        color: Color(0xFF667eea),
                      )
                    : null,
              ),
              const SizedBox(height: 20),
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                email,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                'Provider: ${isGuest ? 'Guest' : provider}',
                style: const TextStyle(fontSize: 14, color: Colors.white54),
              ),
              const SizedBox(height: 40),
              if (!isGuest)
                SizedBox(
                  width: 200,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await authService.signOut();
                      Get.offAllNamed('/login');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF667eea),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              if (isGuest)
                const Text(
                  'You are using the app as a guest. Sign in for more features.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'EventFlow • User Profile',
                  style: TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
