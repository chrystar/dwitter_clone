// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import '../models/notification_model.dart';
//
// class NotificationProvider extends ChangeNotifier {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   List<NotificationModel> _notifications = [];
//
//   List<NotificationModel> get notifications => _notifications;
//   int get unreadCount => _notifications.where((n) => !n.isRead).length;
//
//   // Fetch notifications for current user
//   Future<void> fetchNotifications() async {
//     final user = _auth.currentUser;
//     if (user == null) return;
//
//     try {
//       final snapshot = await _firestore
//           .collection('notifications')
//           .where('receiverUid', isEqualTo: user.uid)
//           .orderBy('timestamp', descending: true)
//           .get();
//
//       _notifications = snapshot.docs
//           .map((doc) => NotificationModel.fromMap(doc.data()))
//           .toList();
//
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error fetching notifications: $e');
//     }
//   }
//
//   // Create a new notification
//   Future<void> createNotification({
//     required String receiverUid,
//     required String type,
//     required String senderUid,
//     String? postId,
//     String? messageId,
//     String? storyId,
//     String? commentId,
//   }) async {
//     try {
//       final notification = NotificationModel(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         type: type,
//         receiverUid: receiverUid,
//         senderUid: senderUid,
//         timestamp: DateTime.now(),
//         isRead: false,
//         postId: postId,
//         messageId: messageId,
//         storyId: storyId,
//         commentId: commentId,
//       );
//
//       // Add to Firestore
//       await _firestore
//           .collection('notifications')
//           .doc(notification.id)
//           .set(notification.toMap());
//
//       // Update unread counter
//       await _updateUnreadCounter(receiverUid, 1);
//
//       // If this is for current user, update local state
//       if (receiverUid == _auth.currentUser?.uid) {
//         _notifications.insert(0, notification);
//         notifyListeners();
//       }
//     } catch (e) {
//       debugPrint('Error creating notification: $e');
//     }
//   }
//
//   // Mark notification as read
//   Future<void> markAsRead(String notificationId) async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) return;
//
//       await _firestore
//           .collection('notifications')
//           .doc(notificationId)
//           .update({'isRead': true});
//
//       // Update local state
//       final index = _notifications.indexWhere((n) => n.id == notificationId);
//       if (index != -1) {
//         _notifications[index] = _notifications[index].copyWith(isRead: true);
//         notifyListeners();
//       }
//
//       // Update unread counter
//       await _updateUnreadCounter(user.uid, -1);
//     } catch (e) {
//       debugPrint('Error marking notification as read: $e');
//     }
//   }
//
//   // Mark all notifications as read
//   Future<void> markAllAsRead() async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) return;
//
//       final batch = _firestore.batch();
//       final unreadNotifications = _notifications.where((n) => !n.isRead);
//
//       for (var notification in unreadNotifications) {
//         batch.update(
//           _firestore.collection('notifications').doc(notification.id),
//           {'isRead': true},
//         );
//       }
//
//       await batch.commit();
//
//       // Update local state
//       _notifications =
//           _notifications.map((n) => n.copyWith(isRead: true)).toList();
//
//       // Reset unread counter
//       await _resetUnreadCounter(user.uid);
//
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error marking all notifications as read: $e');
//     }
//   }
//
//   // Delete a notification
//   Future<void> deleteNotification(String notificationId) async {
//     try {
//       await _firestore.collection('notifications').doc(notificationId).delete();
//
//       // Update local state
//       _notifications.removeWhere((n) => n.id == notificationId);
//       notifyListeners();
//
//       // Update unread counter if needed
//       final user = _auth.currentUser;
//       if (user != null) {
//         final wasUnread =
//             _notifications.any((n) => n.id == notificationId && !n.isRead);
//         if (wasUnread) {
//           await _updateUnreadCounter(user.uid, -1);
//         }
//       }
//     } catch (e) {
//       debugPrint('Error deleting notification: $e');
//     }
//   }
//
//   // Stream of notifications for real-time updates
//   Stream<QuerySnapshot> notificationStream() {
//     final user = _auth.currentUser;
//     if (user == null) return const Stream.empty();
//
//     return _firestore
//         .collection('notifications')
//         .where('receiverUid', isEqualTo: user.uid)
//         .orderBy('timestamp', descending: true)
//         .snapshots();
//   }
//
//   // Private method to update unread counter
//   Future<void> _updateUnreadCounter(String userId, int change) async {
//     try {
//       final counterRef = _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('notifications')
//           .doc('counter');
//
//       await _firestore.runTransaction((transaction) async {
//         final snapshot = await transaction.get(counterRef);
//         final currentCount = (snapshot.data()?['unreadCount'] as int?) ?? 0;
//         transaction.set(
//           counterRef,
//           {'unreadCount': currentCount + change},
//           SetOptions(merge: true),
//         );
//       });
//     } catch (e) {
//       debugPrint('Error updating unread counter: $e');
//     }
//   }
//
//   // Private method to reset unread counter
//   Future<void> _resetUnreadCounter(String userId) async {
//     try {
//       await _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('notifications')
//           .doc('counter')
//           .set({'unreadCount': 0});
//     } catch (e) {
//       debugPrint('Error resetting unread counter: $e');
//     }
//   }
// }
