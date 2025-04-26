import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LikeProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> togglePostLike(String postId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final postRef = _firestore.collection('posts').doc(postId);
    final postDoc = await postRef.get();

    if (!postDoc.exists) return;

    final List<String> likes =
        List<String>.from(postDoc.data()?['likes'] ?? []);
    final bool isLiking = !likes.contains(currentUser.uid);

    if (likes.contains(currentUser.uid)) {
      likes.remove(currentUser.uid);
    } else {
      likes.add(currentUser.uid);

      // Create notification when liking (not when unliking)
      final postData = postDoc.data()!;
      final postAuthorId = postData['userId'] as String;

      // Don't notify if liking own post
      if (postAuthorId != currentUser.uid) {
        await _firestore.collection('notifications').add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'type': 'like',
          'receiverUid': postAuthorId,
          'senderUid': currentUser.uid,
          'postId': postId,
          'timestamp': DateTime.now(),
          'isRead': false,
        });

        // Update unread counter
        final counterRef = _firestore
            .collection('users')
            .doc(postAuthorId)
            .collection('notifications')
            .doc('counter');

        await _firestore.runTransaction((transaction) async {
          final snapshot = await transaction.get(counterRef);
          final currentCount = (snapshot.data()?['unreadCount'] as int?) ?? 0;
          transaction.set(
            counterRef,
            {'unreadCount': currentCount + 1},
            SetOptions(merge: true),
          );
        });
      }
    }

    await postRef.update({'likes': likes});
    notifyListeners();
  }

  Future<void> toggleCommentLike(String postId, String commentId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final commentRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);

    final commentDoc = await commentRef.get();
    if (!commentDoc.exists) return;

    final List<String> likes =
        List<String>.from(commentDoc.data()?['likes'] ?? []);

    if (likes.contains(currentUser.uid)) {
      likes.remove(currentUser.uid);
    } else {
      likes.add(currentUser.uid);
    }

    await commentRef.update({'likes': likes});
    notifyListeners();
  }

  Stream<DocumentSnapshot> getPostLikes(String postId) {
    return _firestore.collection('posts').doc(postId).snapshots();
  }

  Stream<DocumentSnapshot> getCommentLikes(String postId, String commentId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .snapshots();
  }
}
