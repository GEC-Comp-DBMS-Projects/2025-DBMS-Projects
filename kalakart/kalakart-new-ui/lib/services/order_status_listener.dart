import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderStatusListener {
  static final OrderStatusListener _instance = OrderStatusListener._internal();
  factory OrderStatusListener() => _instance;
  OrderStatusListener._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  
  StreamSubscription<QuerySnapshot>? _subscription;
  bool _isInitialized = false;

  // Initialize notifications 
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Basic initialization for Android and iOS (Darwin)
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // Optional: handle older iOS versions' local notification callback
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        // no-op for now
      },
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize plugin and set a simple tap handler
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // You can handle notification tap here (navigate to order details, etc.)
        // final payload = response.payload;
      },
    );

    // Create Android notification channel (required on Android 8+)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'order_updates', // id
      'Order Updates', // title
      description: 'Notifications for order status changes',
      importance: Importance.high,
    );

    try {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    } catch (e) {
      // If channel creation fails, log and continue; notifications may still work on older devices
      print('Error creating notification channel: $e');
    }

    // Note: platform-specific permission requests (Android 13's POST_NOTIFICATIONS
    // and iOS permission prompts) are handled via the initialization flags above.
    // For Android 13+ you should also add the POST_NOTIFICATIONS permission in
    // AndroidManifest.xml and request it at runtime if targeting SDK 33+.

    _isInitialized = true;
  }

  // Public helper to show a test notification (useful during development)
  Future<void> showTestNotification({
    String title = 'Test Notification',
    String body = 'This is a test notification',
  }) async {
    if (!_isInitialized) await initialize();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'order_updates',
      'Order Updates',
      channelDescription: 'Notifications for order status changes',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
    );
  }

  // Start listening to order status changes
  Future<void> startListening(String userId) async {
    await initialize();
    await stopListening();

    print('Starting to listen for orders for user: $userId');
    _subscription = FirebaseFirestore.instance
        .collection('shop_orders')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .listen(
          (snapshot) async {
            print('Received Firestore update with ${snapshot.docChanges.length} changes');
            for (var change in snapshot.docChanges) {
              final orderData = change.doc.data();
              print('Order ${change.doc.id} changed: type=${change.type}, status=${orderData?['order_status']}');
              
              if (change.type == DocumentChangeType.modified) {
                if (orderData != null) {
                  await _checkStatusChange(
                    orderId: change.doc.id,
                    newStatus: orderData['order_status'] ?? '',
                  );
                }
              } else if (change.type == DocumentChangeType.added) {
                if (orderData != null) {
                  await _saveInitialStatus(
                    orderId: change.doc.id,
                    status: orderData['order_status'] ?? '',
                  );
                }
              }
            }
          },
          onError: (error) {
            print('Error listening to orders: $error');
          },
        );
  }

  // Stop listening
  Future<void> stopListening() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  // Save initial status for new orders
  Future<void> _saveInitialStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('order_status_$orderId', status);
    } catch (e) {
      print('Error saving initial status: $e');
    }
  }

  // Check if status has changed
  Future<void> _checkStatusChange({
    required String orderId,
    required String newStatus,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String key = 'order_status_$orderId';
      String? oldStatus = prefs.getString(key);

      if (oldStatus != null && oldStatus != newStatus && newStatus.isNotEmpty) {
        String? productNames;
        try {
          // Fetch order details to get product information
          final orderDoc = await FirebaseFirestore.instance
              .collection('shop_orders')
              .doc(orderId)
              .get();
          
          if (orderDoc.exists) {
            final orderData = orderDoc.data();
            if (orderData != null && orderData['products'] != null) {
              List<dynamic> products = orderData['products'];
              productNames = products.map((p) => p['name'].toString()).join(', ');
            }
          }
        } catch (e) {
          print('Error fetching order details: $e');
        }
        
        // Show notification regardless of whether we got product names
        await showStatusChangeNotification(
          orderId: orderId,
          newStatus: newStatus,
          productNames: productNames,
        );
      }

      await prefs.setString(key, newStatus);
    } catch (e) {
      print('Error checking status change: $e');
    }
  }

  // Show notification for status change
  Future<void> showStatusChangeNotification({
    required String orderId,
    required String newStatus,
    String? productNames,
  }) async {
    print('Showing notification for order: $orderId, status: $newStatus');
    
    if (!_isInitialized) {
      print('Initializing notifications...');
      await initialize();
    }
    
    final String statusText = _getStatusText(newStatus);
    final String displayName = productNames ?? 'Order #${orderId.substring(0, 8).toUpperCase()}';
    print('Notification text: Status=$statusText, Display=$displayName');

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'order_updates',
      'Order Updates',
      channelDescription: 'Notifications for order status changes',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      orderId.hashCode,
      '$statusText Update! 🎉',
      'Your order for $displayName is now ${statusText.toLowerCase()}',
      details,
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  void dispose() {
    stopListening();
  }
}