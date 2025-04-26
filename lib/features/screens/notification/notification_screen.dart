import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dwitter_clone/theme/app_theme.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: XDarkThemeColors.secondaryBackground,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: XDarkThemeColors.primaryText),),
        backgroundColor: XDarkThemeColors.secondaryBackground,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications yet'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final notification =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: notification['senderProfilePic'] != null
                      ? NetworkImage(notification['senderProfilePic'])
                      : null,
                  child: notification['senderProfilePic'] == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.white),
                    children: [
                      TextSpan(
                        text: notification['senderName'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: _getNotificationText(notification['type']),
                      ),
                    ],
                  ),
                ),
                subtitle: Text(
                  timeago.format(
                    (notification['timestamp'] as Timestamp).toDate(),
                  ),
                  style: const TextStyle(color: Colors.grey),
                ),
                onTap: () {
                  // Navigate to the relevant content based on notification type
                  _handleNotificationTap(notification);
                },
              );
            },
          );
        },
      ),
    );
  }

  String _getNotificationText(String type) {
    switch (type) {
      case 'follow':
        return ' started following you';
      case 'like':
        return ' liked your post';
      case 'comment':
        return ' commented on your post';
      default:
        return '';
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    // Handle navigation based on notification type
    switch (notification['type']) {
      case 'follow':
        // Navigate to user profile
        break;
      case 'like':
      case 'comment':
        // Navigate to the specific post
        break;
    }
  }
}
