import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String? id;
  final String title;
  final String description;
  final String category;
  final DateTime date;
  final String time;
  final String venue;
  final double price;
  final int availableSeats;
  final String organizer;
  final List<String> tags;
  final bool isActive;
  final String thumbnail;
  final List<String> eventImages;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventModel({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.time,
    required this.venue,
    required this.price,
    required this.availableSeats,
    required this.organizer,
    required this.tags,
    this.isActive = true,
    required this.thumbnail,
    required this.eventImages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    DateTime now = DateTime.now();
    DateTime createdAt = now;
    DateTime updatedAt = now;

    try {
      if (data['createdAt'] != null) {
        createdAt = (data['createdAt'] as Timestamp).toDate();
      }
    } catch (e) {
      print('Error parsing createdAt: $e');
    }

    try {
      if (data['updatedAt'] != null) {
        updatedAt = (data['updatedAt'] as Timestamp).toDate();
      }
    } catch (e) {
      print('Error parsing updatedAt: $e');
    }

    DateTime eventDate = now.add(const Duration(days: 7));
    try {
      if (data['date'] != null) {
        eventDate = (data['date'] as Timestamp).toDate();
      }
    } catch (e) {
      print('Error parsing date: $e');
    }

    return EventModel(
      id: doc.id,
      title: data['title']?.toString() ?? 'Untitled Event',
      description: data['description']?.toString() ?? '',
      category: data['category']?.toString() ?? 'General',
      date: eventDate,
      time: data['time']?.toString() ?? '12:00 PM',
      venue: data['venue']?.toString() ?? '',
      price: _parseDouble(data['price']),
      availableSeats: _parseInt(data['availableSeats']),
      organizer: data['organizer']?.toString() ?? '',
      tags: _parseStringList(data['tags']),
      isActive: data['isActive'] ?? true,
      thumbnail: data['thumbnail']?.toString() ?? '',
      eventImages: _parseStringList(data['eventImages']),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((item) => item?.toString() ?? '')
          .where((str) => str.isNotEmpty)
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title.trim(),
      'description': description.trim(),
      'category': category.trim(),
      'date': Timestamp.fromDate(date),
      'time': time.trim(),
      'venue': venue.trim(),
      'price': price,
      'availableSeats': availableSeats,
      'organizer': organizer.trim(),
      'tags': tags.where((tag) => tag.isNotEmpty).toList(),
      'isActive': isActive,
      'thumbnail': thumbnail.trim(),
      'eventImages': eventImages.where((img) => img.isNotEmpty).toList(),
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
    String? thumbnail,
    List<String>? eventImages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      time: time ?? this.time,
      venue: venue ?? this.venue,
      price: price ?? this.price,
      availableSeats: availableSeats ?? this.availableSeats,
      organizer: organizer ?? this.organizer,
      tags: tags ?? List.from(this.tags),
      isActive: isActive ?? this.isActive,
      thumbnail: thumbnail ?? this.thumbnail,
      eventImages: eventImages ?? List.from(this.eventImages),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get primaryImage => thumbnail.isNotEmpty ? thumbnail : '';
  String get displayImage => primaryImage.isNotEmpty ? primaryImage : '';
  bool get hasImages => thumbnail.isNotEmpty || eventImages.isNotEmpty;
  bool get hasThumbnail => thumbnail.isNotEmpty;

  List<String> get allImages {
    List<String> images = [];
    if (thumbnail.isNotEmpty) images.add(thumbnail);
    images.addAll(eventImages.where((img) => img.isNotEmpty));
    return images;
  }

  @override
  String toString() {
    return 'EventModel(id: $id, title: $title, thumbnail: $thumbnail, eventImages: ${eventImages.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
