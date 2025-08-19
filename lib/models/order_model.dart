import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String? id;
  final String eventId;
  final String userId;
  final String eventTitle;
  final String eventImageUrl;
  final String eventCategory;
  final DateTime eventDate;
  final String eventTime;
  final String venue;
  final int quantity;
  final double totalAmount;
  final double pricePerTicket;
  final String paymentId;
  final String paymentMethod;
  final String status; // 'confirmed', 'cancelled', 'completed'
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    this.id,
    required this.eventId,
    required this.userId,
    required this.eventTitle,
    required this.eventImageUrl,
    required this.eventCategory,
    required this.eventDate,
    required this.eventTime,
    required this.venue,
    required this.quantity,
    required this.totalAmount,
    required this.pricePerTicket,
    required this.paymentId,
    required this.paymentMethod,
    required this.status,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      userId: data['userId'] ?? '',
      eventTitle: data['eventTitle'] ?? '',
      eventImageUrl: data['eventImageUrl'] ?? '',
      eventCategory: data['eventCategory'] ?? '',
      eventDate: (data['eventDate'] as Timestamp).toDate(),
      eventTime: data['eventTime'] ?? '',
      venue: data['venue'] ?? '',
      quantity: data['quantity'] ?? 0,
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      pricePerTicket: (data['pricePerTicket'] ?? 0).toDouble(),
      paymentId: data['paymentId'] ?? '',
      paymentMethod: data['paymentMethod'] ?? '',
      status: data['status'] ?? 'confirmed',
      customerName: data['customerName'] ?? '',
      customerEmail: data['customerEmail'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'userId': userId,
      'eventTitle': eventTitle,
      'eventImageUrl': eventImageUrl,
      'eventCategory': eventCategory,
      'eventDate': Timestamp.fromDate(eventDate),
      'eventTime': eventTime,
      'venue': venue,
      'quantity': quantity,
      'totalAmount': totalAmount,
      'pricePerTicket': pricePerTicket,
      'paymentId': paymentId,
      'paymentMethod': paymentMethod,
      'status': status,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  OrderModel copyWith({
    String? id,
    String? eventId,
    String? userId,
    String? eventTitle,
    String? eventImageUrl,
    String? eventCategory,
    DateTime? eventDate,
    String? eventTime,
    String? venue,
    int? quantity,
    double? totalAmount,
    double? pricePerTicket,
    String? paymentId,
    String? paymentMethod,
    String? status,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      eventTitle: eventTitle ?? this.eventTitle,
      eventImageUrl: eventImageUrl ?? this.eventImageUrl,
      eventCategory: eventCategory ?? this.eventCategory,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      venue: venue ?? this.venue,
      quantity: quantity ?? this.quantity,
      totalAmount: totalAmount ?? this.totalAmount,
      pricePerTicket: pricePerTicket ?? this.pricePerTicket,
      paymentId: paymentId ?? this.paymentId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper method to check if order is active
  bool get isActive => status != 'cancelled';

  // Helper method to check if order can be cancelled
  bool get canCancel {
    return status == 'confirmed' && eventDate.isAfter(DateTime.now());
  }

  // Helper method to format order display name
  String get displayId {
    return id != null ? 'ORD${id!.substring(0, 8).toUpperCase()}' : 'Unknown';
  }

  // Helper method to get days until event
  int get daysUntilEvent {
    return eventDate.difference(DateTime.now()).inDays;
  }

  // Helper method to check if event is past
  bool get isPastEvent {
    return eventDate.isBefore(DateTime.now());
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, eventTitle: $eventTitle, quantity: $quantity, totalAmount: $totalAmount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
