import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF667eea,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.privacy_tip_outlined,
                                  size: 48,
                                  color: Color(0xFF667eea),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Your Privacy Matters',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Last updated: ${_getFormattedDate()}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Introduction
                        _buildSection(
                          title: 'Introduction',
                          content:
                              'Welcome to EventHub, your trusted event booking platform. We are committed to protecting your personal information and your right to privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and services.',
                        ),

                        // Information We Collect
                        _buildSection(
                          title: 'Information We Collect',
                          content: '',
                          children: [
                            _buildSubSection(
                              title: 'Personal Information',
                              content:
                                  'When you create an account, we collect:\n• Full name and email address\n• Phone number\n• Profile picture (optional)\n• Payment information for transactions\n• Location data for event recommendations',
                            ),
                            _buildSubSection(
                              title: 'Usage Data',
                              content:
                                  'We automatically collect:\n• App usage patterns and preferences\n• Device information and identifiers\n• Event browsing and booking history\n• Search queries and interactions',
                            ),
                            _buildSubSection(
                              title: 'Location Information',
                              content:
                                  'With your permission, we collect location data to:\n• Show nearby events\n• Provide location-based recommendations\n• Improve our services and user experience',
                            ),
                          ],
                        ),

                        // How We Use Your Information
                        _buildSection(
                          title: 'How We Use Your Information',
                          content: '',
                          children: [
                            _buildInfoCard(
                              icon: Icons.event_available,
                              title: 'Event Services',
                              description:
                                  'Process bookings, send confirmations, and manage your event attendance.',
                            ),
                            _buildInfoCard(
                              icon: Icons.recommend,
                              title: 'Personalization',
                              description:
                                  'Provide personalized event recommendations based on your interests.',
                            ),
                            _buildInfoCard(
                              icon: Icons.support_agent,
                              title: 'Customer Support',
                              description:
                                  'Respond to your inquiries and provide technical support.',
                            ),
                            _buildInfoCard(
                              icon: Icons.security,
                              title: 'Security & Safety',
                              description:
                                  'Detect and prevent fraud, abuse, and security incidents.',
                            ),
                          ],
                        ),

                        // Information Sharing
                        _buildSection(
                          title: 'Information Sharing',
                          content:
                              'We do not sell your personal information. We may share your information only in these circumstances:',
                          children: [
                            _buildBulletPoint(
                              'With event organizers when you book their events',
                            ),
                            _buildBulletPoint(
                              'With service providers who help us operate our platform',
                            ),
                            _buildBulletPoint(
                              'When required by law or to protect our rights',
                            ),
                            _buildBulletPoint(
                              'With your explicit consent for specific purposes',
                            ),
                          ],
                        ),

                        // Data Security
                        _buildSection(
                          title: 'Data Security',
                          content:
                              'We implement industry-standard security measures to protect your information:',
                          children: [
                            _buildSecurityFeature(
                              icon: Icons.lock,
                              title: 'Encryption',
                              description:
                                  'All data is encrypted in transit and at rest',
                            ),
                            _buildSecurityFeature(
                              icon: Icons.verified_user,
                              title: 'Secure Authentication',
                              description:
                                  'Multi-factor authentication and secure login',
                            ),
                            _buildSecurityFeature(
                              icon: Icons.monitor,
                              title: 'Continuous Monitoring',
                              description:
                                  '24/7 security monitoring and threat detection',
                            ),
                          ],
                        ),

                        // Your Rights
                        _buildSection(
                          title: 'Your Privacy Rights',
                          content: 'You have the right to:',
                          children: [
                            _buildRightItem(
                              icon: Icons.visibility,
                              title: 'Access',
                              description:
                                  'View and download your personal data',
                            ),
                            _buildRightItem(
                              icon: Icons.edit,
                              title: 'Update',
                              description: 'Correct or update your information',
                            ),
                            _buildRightItem(
                              icon: Icons.delete,
                              title: 'Delete',
                              description:
                                  'Request deletion of your account and data',
                            ),
                            _buildRightItem(
                              icon: Icons.block,
                              title: 'Opt-out',
                              description:
                                  'Unsubscribe from marketing communications',
                            ),
                          ],
                        ),

                        // Data Retention
                        _buildSection(
                          title: 'Data Retention',
                          content:
                              'We retain your personal information for as long as necessary to provide our services and comply with legal obligations. Account data is typically retained for 3 years after account closure, unless you request earlier deletion.',
                        ),

                        // Third-Party Services
                        _buildSection(
                          title: 'Third-Party Services',
                          content:
                              'Our app integrates with third-party services that have their own privacy policies:',
                          children: [
                            _buildThirdPartyService(
                              'Google Maps',
                              'Location services',
                            ),
                            _buildThirdPartyService(
                              'Payment Processors',
                              'Secure payment processing',
                            ),
                            _buildThirdPartyService(
                              'Analytics Services',
                              'App performance and usage analytics',
                            ),
                            _buildThirdPartyService(
                              'Cloud Storage',
                              'Data backup and storage',
                            ),
                          ],
                        ),

                        // Children's Privacy
                        _buildSection(
                          title: 'Children\'s Privacy',
                          content:
                              'Our services are not intended for children under 13. We do not knowingly collect personal information from children under 13. If you believe we have collected information from a child under 13, please contact us immediately.',
                        ),

                        // Changes to Policy
                        _buildSection(
                          title: 'Changes to This Policy',
                          content:
                              'We may update this Privacy Policy from time to time. We will notify you of any material changes by posting the new policy in the app and updating the "Last updated" date. Your continued use of our services after such changes constitutes acceptance of the updated policy.',
                        ),

                        // Contact Information
                        _buildContactSection(),

                        const SizedBox(height: 32),

                        // Footer
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.shield_outlined,
                                size: 32,
                                color: Color(0xFF667eea),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Privacy Protected',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Your trust is important to us. We are committed to protecting your privacy and being transparent about our data practices.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    List<Widget>? children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          if (content.isNotEmpty)
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey[700],
              ),
            ),
          if (children != null) ...[
            if (content.isNotEmpty) const SizedBox(height: 16),
            ...children,
          ],
        ],
      ),
    );
  }

  Widget _buildSubSection({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
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
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
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
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, right: 12),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF667eea),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityFeature({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF667eea).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF667eea).withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
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
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF667eea).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF667eea), size: 24),
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
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThirdPartyService(String name, String purpose) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.link, size: 16, color: Color(0xFF667eea)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                children: [
                  TextSpan(
                    text: '$name: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: purpose),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF667eea).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF667eea).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Us',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'If you have any questions about this Privacy Policy or our data practices, please contact us:',
            style: TextStyle(fontSize: 16, color: Color(0xFF2D3748)),
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.email_outlined,
            title: 'Email',
            value: 'support@eventbooking.com',
          ),
          _buildContactItem(
            icon: Icons.phone_outlined,
            title: 'Phone',
            value: '+91 8737018483',
          ),
          _buildContactItem(
            icon: Icons.location_on_outlined,
            title: 'Address',
            value: 'B-18, Block-B, Sector 1, Lucknow, Uttar Pradesh, India',
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF667eea), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Color(0xFF2D3748)),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}
