import 'package:event_management/helpers/firebase_helpers.dart';
import 'package:event_management/shared/event_card.dart';
import 'package:event_management/shared/slider_banners_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/event_model.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../services/profile_service.dart';
import 'event_list_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EventService eventService = Get.put(EventService());
  final ProfileService profileService = Get.put(ProfileService());
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authService = Get.find<AuthService>();
    final userId = authService.user?.uid;
    if (userId != null) {
      profileService.fetchProfile(userId);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              _buildHeader(),
              _buildSearchBar(),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: 10,
                      children: [
                        const SizedBox(height: 1),
                        _buildFeaturedEventsCarousel(),
                        _buildWelcomeMessage(),
                        _buildUpcomingEventsSection(),
                        _buildPopularEventsSection(),
                        _buildRecentEventsSection(),
                        const SizedBox(height: 25),
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

  Widget _buildHeader() {
    final authService = Get.find<AuthService>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Event Booking',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Discover Amazing Events',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.to(() => const ProfileScreen()),
            child: Obx(() {
              final profile = profileService.profile.value;
              final email = authService.getCurrentUserEmail();
              final String firstLetter = (email != null && email.isNotEmpty)
                  ? email[0].toUpperCase()
                  : '?';

              final String fallbackLetter = (profile?.name.isNotEmpty == true)
                  ? profile!.name[0].toUpperCase()
                  : firstLetter;

              if (profile?.photoUrl == "" || profile?.photoUrl == null) {
                return Container(
                  height: 50,
                  width: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 113, 139, 255),
                  ),
                  child: Center(
                    child: Text(
                      fallbackLetter,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }
              return Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 140, 158, 234),
                ),
                child: ClipOval(
                  child: buildProfileImage(
                    profile?.photoUrl,
                    width: 48,
                    height: 48,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onTap: () {
            Get.to(() => EventListScreen());
          },
          readOnly: true,
          decoration: const InputDecoration(
            hintText: 'Search events...',
            prefixIcon: Icon(Icons.search, color: Color(0xFF667eea)),
            suffixIcon: Icon(Icons.tune, color: Color(0xFF667eea)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedEventsCarousel() {
    return Obx(() {
      List<EventModel> featuredEvents = eventService.events.take(5).toList();

      return SharedSliders(
        events: featuredEvents,
        showDots: true,
        autoSlide: true,
        height: 220,
      );
    });
  }

  Widget _buildWelcomeMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Obx(() {
            final profile = profileService.profile.value;
            final authService = Get.find<AuthService>();

            // Get user name from profile first, then fallback to auth display name
            String userName = '';
            if (profile?.name.isNotEmpty == true) {
              userName = profile!.name;
            } else if (authService.getCurrentUserDisplayName()?.isNotEmpty ==
                true) {
              userName = authService.getCurrentUserDisplayName()!;
            }

            return Text(
              userName.isNotEmpty
                  ? 'Hello, ${userName.split(' ').first} 👋'
                  : 'Hello! 👋',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            );
          }),
          const SizedBox(height: 8),
          Text(
            'What event are you looking for today?',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsSection() {
    return Obx(() {
      List<EventModel> upcomingEvents = eventService.events
          .where((event) => event.date.isAfter(DateTime.now()))
          .take(5)
          .toList();

      if (upcomingEvents.isEmpty) {
        upcomingEvents = eventService.events.take(3).toList();
      }

      return _buildEventSection(
        title: 'Upcoming Events',
        events: upcomingEvents,
      );
    });
  }

  Widget _buildPopularEventsSection() {
    return Obx(() {
      List<EventModel> popularEvents = eventService.events
          .where((event) => event.availableSeats < 100 || event.price > 100)
          .take(5)
          .toList();

      if (popularEvents.isEmpty) {
        popularEvents = eventService.events.take(3).toList();
      }

      return _buildEventSection(title: 'Popular Events', events: popularEvents);
    });
  }

  Widget _buildRecentEventsSection() {
    return Obx(() {
      List<EventModel> recentEvents = eventService.events
          .where(
            (event) => event.createdAt.isAfter(
              DateTime.now().subtract(const Duration(days: 7)),
            ),
          )
          .take(5)
          .toList();

      if (recentEvents.isEmpty) {
        recentEvents = eventService.events.reversed.take(3).toList();
      }

      return _buildEventSection(title: 'Recent Events', events: recentEvents);
    });
  }

  Widget _buildEventSection({
    required String title,
    required List<EventModel> events,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  eventService.filterByCategory('');
                  Get.to(() => EventListScreen());
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF667eea),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: events.length,
            itemBuilder: (context, index) {
              return SharedCard(
                event: events[index],
                cardType: CardType.horizontal,
                width: 250,
                height: 280,
              );
            },
          ),
        ),
      ],
    );
  }
}
