// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../services/event_service.dart';
import '../models/event_model.dart';
import 'event_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EventService eventService = Get.put(EventService());
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Track the selected category locally to ensure UI reflects changes immediately
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    // Add some sample events if the list is empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (eventService.events.isEmpty) {
        _addSampleEvents();
      }
      // Sync local state with service state
      setState(() {
        _selectedCategory = eventService.selectedCategory.value;
      });
      // Listen to changes in the service's selectedCategory
      ever(eventService.selectedCategory, (value) {
        setState(() {
          _selectedCategory = value;
        });
      });
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
      EventModel(
        title: 'Charity Run 10K',
        description:
            'Participate in a 10K run to support local charities and promote fitness.',
        category: 'Sports',
        imageUrl:
            'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=500',
        date: DateTime.now().add(const Duration(days: 18)),
        time: '07:00 AM',
        venue: 'Riverside Park',
        price: 30.00,
        availableSeats: 400,
        organizer: 'Charity Foundation',
        tags: ['Sports', 'Charity', 'Run'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EventModel(
        title: 'Coding Bootcamp',
        description:
            'Intensive coding bootcamp for beginners and intermediate learners.',
        category: 'Technology',
        imageUrl:
            'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=500',
        date: DateTime.now().add(const Duration(days: 15)),
        time: '09:00 AM',
        venue: 'Tech Lab',
        price: 199.99,
        availableSeats: 60,
        organizer: 'Code School',
        tags: ['Technology', 'Coding', 'Bootcamp'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EventModel(
        title: 'Jazz Night',
        description:
            'Enjoy a night of smooth jazz with live performances from top artists.',
        category: 'Music',
        imageUrl:
            'https://images.unsplash.com/photo-1465101178521-c1a9136a3b99?w=500',
        date: DateTime.now().add(const Duration(days: 9)),
        time: '08:00 PM',
        venue: 'Downtown Club',
        price: 45.00,
        availableSeats: 120,
        organizer: 'Jazz Society',
        tags: ['Music', 'Jazz', 'Live'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EventModel(
        title: 'Startup Legal Basics',
        description:
            'A seminar on legal essentials for startups and entrepreneurs.',
        category: 'Business',
        imageUrl:
            'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?w=500',
        date: DateTime.now().add(const Duration(days: 11)),
        time: '04:00 PM',
        venue: 'Law Center',
        price: 40.00,
        availableSeats: 70,
        organizer: 'Legal Experts',
        tags: ['Business', 'Legal', 'Seminar'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EventModel(
        title: 'Modern Dance Show',
        description:
            'A spectacular modern dance performance by renowned artists.',
        category: 'Art',
        imageUrl:
            'https://images.unsplash.com/photo-1464983953574-0892a716854b?w=500',
        date: DateTime.now().add(const Duration(days: 13)),
        time: '07:30 PM',
        venue: 'City Theater',
        price: 55.00,
        availableSeats: 180,
        organizer: 'Dance Company',
        tags: ['Art', 'Dance', 'Performance'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EventModel(
        title: 'Science Fair',
        description:
            'Explore exciting science projects and experiments at the annual fair.',
        category: 'Education',
        imageUrl:
            'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?w=500',
        date: DateTime.now().add(const Duration(days: 16)),
        time: '10:00 AM',
        venue: 'Community Center',
        price: 10.00,
        availableSeats: 250,
        organizer: 'Science Club',
        tags: ['Education', 'Science', 'Fair'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EventModel(
        title: 'Healthy Cooking Class',
        description:
            'Learn to cook healthy and delicious meals with our expert chefs.',
        category: 'Food',
        imageUrl:
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=500',
        date: DateTime.now().add(const Duration(days: 6)),
        time: '03:00 PM',
        venue: 'Cooking Studio',
        price: 35.00,
        availableSeats: 25,
        organizer: 'Healthy Eats',
        tags: ['Food', 'Cooking', 'Health'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      // 6 more events to make 20
      EventModel(
        title: 'Book Reading Night',
        description:
            'Join us for a cozy evening of book readings and discussions with local authors.',
        category: 'Education',
        imageUrl:
            'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=500',
        date: DateTime.now().add(const Duration(days: 17)),
        time: '06:30 PM',
        venue: 'City Library',
        price: 0.0,
        availableSeats: 60,
        organizer: 'Book Lovers Club',
        tags: ['Education', 'Books', 'Reading'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EventModel(
        title: 'Wine Tasting Gala',
        description:
            'Sample exquisite wines from around the world at our annual gala.',
        category: 'Food',
        imageUrl:
            'https://images.unsplash.com/photo-1514361892635-cebb9b6b9d49?w=500',
        date: DateTime.now().add(const Duration(days: 19)),
        time: '07:00 PM',
        venue: 'Grand Ballroom',
        price: 75.00,
        availableSeats: 90,
        organizer: 'Wine Society',
        tags: ['Food', 'Wine', 'Gala'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EventModel(
        title: 'Startup Demo Day',
        description:
            'See the latest innovations as startups demo their products.',
        category: 'Business',
        imageUrl:
            'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=500',
        date: DateTime.now().add(const Duration(days: 21)),
        time: '01:00 PM',
        venue: 'Tech Park',
        price: 0.0,
        availableSeats: 200,
        organizer: 'Startup Hub',
        tags: ['Business', 'Demo', 'Startup'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EventModel(
        title: 'Marathon 2024',
        description:
            'Join the city marathon and challenge yourself for a good cause.',
        category: 'Sports',
        imageUrl:
            'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=500',
        date: DateTime.now().add(const Duration(days: 22)),
        time: '06:00 AM',
        venue: 'City Stadium',
        price: 50.00,
        availableSeats: 1000,
        organizer: 'Sports Association',
        tags: ['Sports', 'Marathon', 'Charity'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EventModel(
        title: 'Painting Masterclass',
        description: 'A hands-on painting masterclass with a renowned artist.',
        category: 'Art',
        imageUrl:
            'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=500',
        date: DateTime.now().add(const Duration(days: 23)),
        time: '11:00 AM',
        venue: 'Art Studio',
        price: 80.00,
        availableSeats: 40,
        organizer: 'Art Masters',
        tags: ['Art', 'Painting', 'Workshop'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EventModel(
        title: 'Health & Nutrition Seminar',
        description:
            'Learn about the latest in health and nutrition from experts.',
        category: 'Health',
        imageUrl:
            'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=500',
        date: DateTime.now().add(const Duration(days: 24)),
        time: '10:00 AM',
        venue: 'Wellness Center',
        price: 20.00,
        availableSeats: 120,
        organizer: 'Health First',
        tags: ['Health', 'Nutrition', 'Seminar'],
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
    _scrollController.dispose();
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
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.event,
                        color: Color(0xFF667eea),
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EventFlow',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Discover Amazing Events',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Get.toNamed('/profile');
                      },
                      icon: const Icon(
                        Icons.account_circle,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Get.toNamed('/event-list');
                      },
                      icon: const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
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
                    onChanged: (value) => eventService.searchEvents(value),
                    decoration: const InputDecoration(
                      hintText: 'Search events...',
                      prefixIcon: Icon(Icons.search, color: Color(0xFF667eea)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Category Filter
              GetBuilder<EventService>(
                id: 'categoryFilter',
                builder: (_) {
                  List<String> categories = eventService.getCategories();
                  return SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: categories.length + 1,
                      itemBuilder: (context, index) {
                        String category;
                        bool isSelected;
                        if (index == 0) {
                          category = 'All';
                          isSelected = _selectedCategory.isEmpty;
                        } else {
                          category = categories[index - 1];
                          isSelected = _selectedCategory == category;
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            label: Text(
                              category,
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF667eea)
                                    : Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: Colors.white,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            side: const BorderSide(
                              color: Colors.white,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  if (category == 'All') {
                                    _selectedCategory = '';
                                    eventService.selectedCategory.value = '';
                                    eventService.filterByCategory('');
                                  } else {
                                    _selectedCategory = category;
                                    eventService.selectedCategory.value =
                                        category;
                                    eventService.filterByCategory(category);
                                  }
                                });
                                // Update GetBuilder
                                eventService.update(['categoryFilter']);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Events List
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Obx(() {
                    if (eventService.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF667eea),
                          ),
                        ),
                      );
                    }

                    if (eventService.filteredEvents.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'No events found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: eventService.filteredEvents.length,
                      itemBuilder: (context, index) {
                        EventModel event = eventService.filteredEvents[index];
                        return _buildEventCard(event);
                      },
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

  // The _buildCategoryChip method is now inlined above for correct state handling.

  Widget _buildEventCard(EventModel event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            // Event Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                image: DecorationImage(
                  image: NetworkImage(event.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
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
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF667eea),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          event.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 5),
                      Text(
                        DateFormat('MMM dd, yyyy').format(event.date),
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 20),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 5),
                      Text(
                        event.time,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          event.venue,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${event.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF667eea),
                        ),
                      ),
                      Text(
                        '${event.availableSeats} seats left',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
