import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../models/order_model.dart';
import '../models/event_model.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/event_service.dart';

class OrdersService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService authService = Get.find<AuthService>();
  final ProfileService profileService = Get.find<ProfileService>();
  final EventService eventService = Get.find<EventService>();

  var isLoading = false.obs;
  var orders = <OrderModel>[].obs;
  var filteredOrders = <OrderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserOrders();
  }

  Future<bool> createOrder({
    required EventModel event,
    required int quantity,
    required String paymentId,
    required String paymentMethod,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
  }) async {
    try {
      final userId = authService.user?.uid;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now();
      final totalAmount = event.price * quantity;

      final order = OrderModel(
        eventId: event.id!,
        userId: userId,
        eventTitle: event.title,
        eventImageUrl: event.imageUrl,
        eventCategory: event.category,
        eventDate: event.date,
        eventTime: event.time,
        venue: event.venue,
        quantity: quantity,
        totalAmount: totalAmount,
        pricePerTicket: event.price,
        paymentId: paymentId,
        paymentMethod: paymentMethod,
        status: 'confirmed',
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
        createdAt: now,
        updatedAt: now,
      );

      final docRef = await _firestore
          .collection('orders')
          .add(order.toFirestore());

      final orderWithId = order.copyWith(id: docRef.id);
      orders.insert(0, orderWithId);
      filteredOrders.insert(0, orderWithId);

      return true;
    } catch (e) {
      print('Error creating order: $e');
      return false;
    }
  }

  Future<void> fetchUserOrders() async {
    try {
      isLoading.value = true;

      final userId = authService.user?.uid;

      if (userId == null) {
        print('User not authenticated');
        return;
      }

      if (profileService.profile.value == null) {
        await profileService.fetchProfile(userId);
      }

      final querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final ordersList = querySnapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();

      for (int i = 0; i < ordersList.length; i++) {
        try {
          final eventDoc = await _firestore
              .collection('events')
              .doc(ordersList[i].eventId)
              .get();

          if (eventDoc.exists) {
            final eventData = EventModel.fromFirestore(eventDoc);
            ordersList[i] = ordersList[i].copyWith(
              eventTitle: eventData.title,
              eventImageUrl: eventData.imageUrl,
              venue: eventData.venue,
              eventCategory: eventData.category,
            );
          }
        } catch (e) {
          print('Error fetching event data for order ${ordersList[i].id}: $e');
        }
      }

      orders.value = ordersList;
      filteredOrders.value = ordersList;
    } catch (e) {
      print('Error fetching orders: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch orders',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void filterOrders(String status) {
    if (status == 'All') {
      filteredOrders.value = orders;
    } else {
      filteredOrders.value = orders
          .where((order) => order.status.toLowerCase() == status.toLowerCase())
          .toList();
    }
  }

  void searchOrders(String query) {
    if (query.isEmpty) {
      filteredOrders.value = orders;
    } else {
      filteredOrders.value = orders
          .where(
            (order) =>
                order.eventTitle.toLowerCase().contains(query.toLowerCase()) ||
                order.id!.toLowerCase().contains(query.toLowerCase()) ||
                order.paymentId.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final orderIndex = orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        orders[orderIndex] = orders[orderIndex].copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );

        final filteredIndex = filteredOrders.indexWhere(
          (order) => order.id == orderId,
        );
        if (filteredIndex != -1) {
          filteredOrders[filteredIndex] = filteredOrders[filteredIndex]
              .copyWith(status: newStatus, updatedAt: DateTime.now());
        }
      }

      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  OrderModel? getOrderById(String orderId) {
    try {
      return orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  int get totalOrdersCount => orders.length;

  double get totalSpentAmount {
    return orders
        .where((order) => order.status != 'cancelled')
        .fold(0.0, (total, order) => total + order.totalAmount);
  }

  Future<bool> cancelOrder(String orderId) async {
    final success = await updateOrderStatus(orderId, 'cancelled');
    if (success) {
      Get.snackbar(
        'Success',
        'Order cancelled successfully',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
    return success;
  }

  Future<void> refreshOrders() async {
    await fetchUserOrders();
  }
}
