import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/event_model.dart';

class EventService extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<EventModel> events = <EventModel>[].obs;
  final RxList<EventModel> filteredEvents = <EventModel>[].obs;
  final RxString selectedCategory = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    isLoading.value = true;
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('events')
          .where('isActive', isEqualTo: true)
          .orderBy('date', descending: false)
          .get();

      events.value = querySnapshot.docs
          .map((doc) => EventModel.fromFirestore(doc))
          .toList();

      filteredEvents.value = events;
    } catch (e) {
      print('Error fetching events: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
    if (category.isEmpty) {
      filteredEvents.value = events;
    } else {
      filteredEvents.value = events
          .where(
            (event) => event.category.toLowerCase() == category.toLowerCase(),
          )
          .toList();
    }
  }

  List<String> getCategories() {
    Set<String> categories = events.map((event) => event.category).toSet();
    return categories.toList()..sort();
  }

  EventModel? getEventById(String id) {
    try {
      return events.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> createEvent(EventModel event) async {
    try {
      await _firestore.collection('events').add(event.toFirestore());
      await fetchEvents();
      return true;
    } catch (e) {
      print('Error creating event: $e');
      return false;
    }
  }

  Future<bool> updateEvent(EventModel event) async {
    try {
      await _firestore
          .collection('events')
          .doc(event.id)
          .update(event.toFirestore());
      await fetchEvents();
      return true;
    } catch (e) {
      print('Error updating event: $e');
      return false;
    }
  }

  Future<bool> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
      await fetchEvents();
      return true;
    } catch (e) {
      print('Error deleting event: $e');
      return false;
    }
  }

  Future<bool> bookTicket(String eventId, int quantity) async {
    try {
      EventModel? event = getEventById(eventId);
      if (event != null && event.availableSeats >= quantity) {
        EventModel updatedEvent = event.copyWith(
          availableSeats: event.availableSeats - quantity,
          updatedAt: DateTime.now(),
        );
        return await updateEvent(updatedEvent);
      }
      return false;
    } catch (e) {
      print('Error booking ticket: $e');
      return false;
    }
  }

  void searchEvents(String query) {
    if (query.isEmpty) {
      filteredEvents.value = events;
    } else {
      filteredEvents.value = events
          .where(
            (event) =>
                event.title.toLowerCase().contains(query.toLowerCase()) ||
                event.description.toLowerCase().contains(query.toLowerCase()) ||
                event.venue.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
  }

  List<EventModel> getUpcomingEvents() {
    DateTime now = DateTime.now();
    return events.where((event) => event.date.isAfter(now)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<EventModel> getEventsByDateRange(DateTime start, DateTime end) {
    return events
        .where(
          (event) =>
              event.date.isAfter(start.subtract(const Duration(days: 1))) &&
              event.date.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();
  }
}
