// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/event_model.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../services/profile_service.dart';
import 'event_detail_screen.dart';
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
    // Add some sample events if the list is empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (eventService.events.isEmpty) {
        _addSampleEvents();
      }
    });
  }

  void _addSampleEvents() {
    final List<EventModel> sampleEvents = [
      EventModel(
        title: 'Tech Conference 2024',
        description:
            'Join us for the biggest tech conference of the year featuring industry leaders and innovative technologies.',
        category: 'Technology',
        imageUrl:
            'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=500',
        date: DateTime.now().add(const Duration(days: 7)),
        time: '09:00 AM',
        venue: 'Convention Center',
        price: 299.99,
        availableSeats: 150,
        organizer: 'Tech Events Inc',
        tags: ['Technology', 'Conference', 'Innovation'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EventModel(
        title: 'Music Festival',
        description:
            'Experience the best live music performances from top artists around the world.',
        category: 'Music',
        imageUrl:
            'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=500',
        date: DateTime.now().add(const Duration(days: 14)),
        time: '06:00 PM',
        venue: 'Central Park',
        price: 89.99,
        availableSeats: 500,
        organizer: 'Music Productions',
        tags: ['Music', 'Festival', 'Live Performance'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EventModel(
        title: 'Business Networking',
        description:
            'Connect with industry professionals and expand your business network.',
        category: 'Business',
        imageUrl:
            'https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=500',
        date: DateTime.now().add(const Duration(days: 3)),
        time: '07:00 PM',
        venue: 'Grand Hotel',
        price: 149.99,
        availableSeats: 80,
        organizer: 'Business Network',
        tags: ['Business', 'Networking', 'Professional'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EventModel(
        title: 'Art Exhibition',
        description:
            'Discover amazing artworks from contemporary artists in this exclusive exhibition.',
        category: 'Art',
        imageUrl:
            'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=500',
        date: DateTime.now().add(const Duration(days: 10)),
        time: '10:00 AM',
        venue: 'Modern Art Gallery',
        price: 25.00,
        availableSeats: 200,
        organizer: 'Art Gallery',
        tags: ['Art', 'Exhibition', 'Culture'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EventModel(
        title: 'Startup Pitch Night',
        description:
            'Watch startups pitch their ideas to investors and network with entrepreneurs.',
        category: 'Business',
        imageUrl:
            'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=500',
        date: DateTime.now().add(const Duration(days: 5)),
        time: '05:30 PM',
        venue: 'Innovation Hub',
        price: 0.0,
        availableSeats: 100,
        organizer: 'Startup Community',
        tags: ['Business', 'Startup', 'Pitch'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EventModel(
        title: 'Food Carnival',
        description:
            'Taste delicious cuisines from around the world at our annual food carnival.',
        category: 'Food',
        imageUrl:
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=500',
        date: DateTime.now().add(const Duration(days: 12)),
        time: '12:00 PM',
        venue: 'City Square',
        price: 15.00,
        availableSeats: 300,
        organizer: 'Foodies United',
        tags: ['Food', 'Carnival', 'Cuisine'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EventModel(
        title: 'Yoga & Wellness Retreat',
        description:
            'Relax and rejuvenate with yoga sessions and wellness workshops.',
        category: 'Health',
        imageUrl:
            'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=500',
        date: DateTime.now().add(const Duration(days: 20)),
        time: '08:00 AM',
        venue: 'Mountain Resort',
        price: 120.00,
        availableSeats: 50,
        organizer: 'Wellness Center',
        tags: ['Health', 'Yoga', 'Wellness'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EventModel(
        title: 'Photography Workshop',
        description:
            'Learn photography from professionals and improve your skills.',
        category: 'Education',
        imageUrl:
            'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?w=500',
        date: DateTime.now().add(const Duration(days: 8)),
        time: '02:00 PM',
        venue: 'Art Studio',
        price: 60.00,
        availableSeats: 30,
        organizer: 'Photo Academy',
        tags: ['Education', 'Photography', 'Workshop'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (var event in sampleEvents) {
      eventService.createEvent(event);
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
              // Header
              _buildHeader(),

              // Search Bar
              _buildSearchBar(),

              const SizedBox(height: 20),

              // Main Content
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
                      spacing: 20,
                      children: [
                        const SizedBox(height: 25),
                        _buildWelcomeMessage(),
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
    return Obx(() {
      final profile = profileService.profile.value;
      final email = authService.getCurrentUserEmail();
      final String firstLetter = (email != null && email.isNotEmpty)
          ? email[0].toUpperCase()
          : '?';
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Event Management',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Discover Amazing Events',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Get.to(() => const ProfileScreen()),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF667eea),
                child: Text(
                  (profile?.name.isNotEmpty == true)
                      ? profile!.name[0].toUpperCase()
                      : firstLetter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onTap: () {
            // Navigate to full event list screen with search functionality
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
              userName.isNotEmpty ? 'Hello, $userName! 👋' : 'Hello! 👋',
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

  Widget _buildPopularEventsSection() {
    return Obx(() {
      List<EventModel> popularEvents = eventService.events
          .where((event) => event.availableSeats < 100 || event.price > 100)
          .take(5)
          .toList();

      if (popularEvents.isEmpty) {
        popularEvents = eventService.events.take(3).toList();
      }

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Popular Events',
                  style: TextStyle(
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
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: popularEvents.length,
              itemBuilder: (context, index) {
                return _buildHorizontalEventCard(popularEvents[index]);
              },
            ),
          ),
        ],
      );
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

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Events',
                  style: TextStyle(
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
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: recentEvents.length,
              itemBuilder: (context, index) {
                return _buildHorizontalEventCard(recentEvents[index]);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildHorizontalEventCard(EventModel event) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 15, bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          Get.to(() => EventDetailScreen(event: event));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                image: DecorationImage(
                  image: NetworkImage(event.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF667eea),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          event.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Event Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            DateFormat('MMM dd').format(event.date),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '\$${event.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF667eea),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
