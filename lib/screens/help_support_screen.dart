import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
              // App Bar
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
                        'Help & Support',
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
                      children: [
                        // Header
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF667eea,
                                ).withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.help_outline,
                                size: 48,
                                color: Color(0xFF667eea),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Frequently Asked Questions',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Find answers to common questions or reach out for more support.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Accordion Q&A
                        _buildAccordion(),
                        const SizedBox(height: 28),

                        // Contact support card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF667eea,
                            ).withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(
                                0xFF667eea,
                              ).withValues(alpha: 0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Need More Help?',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Contact our team with your query. We’d love to assist you!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    color: Color(0xFF667eea),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'support@eventhub.com',
                                    style: const TextStyle(
                                      color: Color(0xFF667eea),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.phone_outlined,
                                    color: Color(0xFF667eea),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '+1 (555) 987-6543',
                                    style: const TextStyle(
                                      color: Color(0xFF667eea),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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

  Widget _buildAccordion() {
    final List<FAQData> faqList = [
      FAQData(
        question: "How do I book an event?",
        answer:
            "Tap on your desired event, review the details, and click the 'Book Now' button. "
            "Follow the prompts to confirm and pay for your booking.",
      ),
      FAQData(
        question: "Can I cancel or modify my booking?",
        answer:
            "Yes, go to 'My Bookings', select the upcoming event, and choose the cancel or modify option. "
            "Refunds depend on the organizer's cancellation policy.",
      ),
      FAQData(
        question: "I didn’t receive my confirmation email. What should I do?",
        answer:
            "Please check your spam/junk folder. If you still can’t find it, contact our support team with your account email and event details.",
      ),
      FAQData(
        question: "How can I contact the event organizer?",
        answer:
            "Open your event booking details and use the 'Contact Organizer' button or refer to the organizer contact info provided in the event page.",
      ),
      FAQData(
        question: "Is my payment information secure?",
        answer:
            "Yes. We use industry-standard security and encryption for all payment transactions.",
      ),
    ];

    return ListView.separated(
      shrinkWrap: true,
      primary: false,
      itemCount: faqList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final faq = faqList[index];
        return ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[100]!),
          ),
          title: Text(
            faq.question,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
              fontSize: 16,
            ),
          ),
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Text(
                faq.answer,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class FAQData {
  final String question;
  final String answer;

  FAQData({required this.question, required this.answer});
}
