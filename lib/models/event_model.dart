import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String? id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final DateTime date;
  final String time;
  final String venue;
  final double price;
  final int availableSeats;
  final String organizer;
  final List<String> tags;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventModel({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.date,
    required this.time,
    required this.venue,
    required this.price,
    required this.availableSeats,
    required this.organizer,
    required this.tags,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: data['time'] ?? '',
      venue: data['venue'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      availableSeats: data['availableSeats'] ?? 0,
      organizer: data['organizer'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'date': Timestamp.fromDate(date),
      'time': time,
      'venue': venue,
      'price': price,
      'availableSeats': availableSeats,
      'organizer': organizer,
      'tags': tags,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? imageUrl,
    DateTime? date,
    String? time,
    String? venue,
    double? price,
    int? availableSeats,
    String? organizer,
    List<String>? tags,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      date: date ?? this.date,
      time: time ?? this.time,
      venue: venue ?? this.venue,
      price: price ?? this.price,
      availableSeats: availableSeats ?? this.availableSeats,
      organizer: organizer ?? this.organizer,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
