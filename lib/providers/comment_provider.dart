import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dwitter_clone/models/comment_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

final _fireStore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class CommentProvider extends ChangeNotifier {
  Future<void> addComment(String uid, String postId, String content) async {
    try {
      CommentModel commentModel = CommentModel(
        uid: uid,
        postId: postId,
        content: content,
        timestamp: DateTime.now(),
      );

      final commentDoc = await _fireStore
          .collection("posts")
          .doc(postId)
          .collection('comments')
          .add(commentModel.toMap());

      await _fireStore.collection("posts").doc(postId).update({
        'commentCount': FieldValue.increment(1),
      });

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await _fireStore
          .collection("posts")
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();

      await _fireStore.collection("posts").doc(postId).update({
        'commentCount': FieldValue.increment(-1),
      });

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  Future<String?> getCurrentUserName() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final userDoc =
          await _fireStore.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;
        return userData?['name'] ??
            ['no username'] as String?; // Assuming 'username' field
      }
    }
    return null;
  }

  Future<String?> getPosterUsername(String posterUid) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(posterUid)
          .get();

      if (userSnapshot.exists && userSnapshot.data() != null) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        return userData['name']
            as String?; // Replace 'name' with your actual username field
      } else {
        return 'Unknown User'; // Or handle the case where user data is not found
      }
    } catch (e) {
      print("Error fetching username: $e");
      return 'Error'; // Or handle the error appropriately
    }
  }

  Future<List<CommentModel>> getCommentsForPost(String postId) async {
    try {
      QuerySnapshot commentSnapshot = await _fireStore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .get();

      List<CommentModel> comments = commentSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return CommentModel.fromMap(data);
      }).toList();

      return comments;
    } catch (e) {
      throw Exception('Failed to fetch comments: $e');
    }
  }
}
