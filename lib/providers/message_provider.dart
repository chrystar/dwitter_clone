import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class MessageProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(MessageModel message) async {
    final conversationId =
        getConversationId(message.senderUid, message.receiverUid);

    // Fetch both users' data
    final senderDoc =
        await _firestore.collection('users').doc(message.senderUid).get();
    final receiverDoc =
        await _firestore.collection('users').doc(message.receiverUid).get();

    final senderData = senderDoc.data() ?? {};
    final receiverData = receiverDoc.data() ?? {};

    // Update conversation with user details
    await _firestore.collection('conversations').doc(conversationId).set({
      'participants': [message.senderUid, message.receiverUid],
      'participantDetails': {
        message.senderUid: {
          'username': senderData['username'] ?? 'Unknown User',
          'profileImage': senderData['profileImage'] ?? '',
        },
        message.receiverUid: {
          'username': receiverData['username'] ?? 'Unknown User',
          'profileImage': receiverData['profileImage'] ?? '',
        },
      },
      'lastMessage': message.content,
      'lastMessageTime': message.timestamp,
      'lastMessageSender': message.senderUid,
      'unreadCount': {
        message.receiverUid: FieldValue.increment(1),
      },
    }, SetOptions(merge: true));

    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .add({
      ...message.toMap(),
      'participants': [message.senderUid, message.receiverUid],
    });
  }

  Stream<QuerySnapshot> getMessages(
      String conversationId, String currentUserId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> markMessageAsRead(
      String conversationId, String messageId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .update({'isRead': true});
    } catch (e) {
      debugPrint('Error marking message as read: $e');
      rethrow;
    }
  }

  String getConversationId(String uid1, String uid2) {
    final sortedUids = [uid1, uid2]..sort();
    return '${sortedUids[0]}_${sortedUids[1]}';
  }

  Stream<List<DocumentSnapshot>> getConversationsWithUserData(
      String currentUserId) {
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .asyncMap((conversationsSnapshot) async {
      List<DocumentSnapshot> conversationsWithUserData = [];

      for (var conv in conversationsSnapshot.docs) {
        final data = conv.data() as Map<String, dynamic>;
        final participants = List<String>.from(data['participants'] ?? []);
        final participantDetails =
            data['participantDetails'] as Map<dynamic, dynamic>?;

        if (participants.contains(currentUserId)) {
          final otherUserId = participants.firstWhere(
            (id) => id != currentUserId,
            orElse: () => '',
          );

          if (otherUserId.isNotEmpty && participantDetails != null) {
            final otherUserData = participantDetails[otherUserId];
            if (otherUserData != null) {
              final userDoc =
                  await _firestore.collection('users').doc(otherUserId).get();
              conversationsWithUserData.add(userDoc);
            }
          }
        }
      }

      return conversationsWithUserData;
    });
  }

  Stream<int> getTotalUnreadCount(String userId) {
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      int total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final unreadCount =
            (data['unreadCount'] as Map<String, dynamic>?)?[userId] ?? 0;
        total += unreadCount as int;
      }
      return total;
    });
  }

  Future<void> markConversationAsRead(
      String conversationId, String userId) async {
    await _firestore.collection('conversations').doc(conversationId).set({
      'unreadCount': {
        userId: 0,
      },
    }, SetOptions(merge: true));
  }

  Future<void> markAsRead(String conversationId, String userId) async {
    await _firestore.collection('conversations').doc(conversationId).update({
      'unreadCount.$userId': 0,
    });
  }
}
