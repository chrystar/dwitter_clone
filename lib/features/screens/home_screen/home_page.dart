import 'package:dwitter_clone/features/widgets/Ddrawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:stories_for_flutter/stories_for_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../theme/app_theme.dart';
import '../post/post_detail_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class _HomePageState extends State<HomePage> {
  User? user = _auth.currentUser;

  final storyProfile = _firestore.collection('users').doc('profileImage');

  Stream<QuerySnapshot> getAllPost() {
    return _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<DocumentSnapshot?> getUserData(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: XDarkThemeColors.secondaryBackground,
      body: Padding(
        padding: EdgeInsets.only(top: 10),
        child: StreamBuilder(
          stream: getAllPost(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No posts yet.'));
            }

            if (snapshot.hasError) {
              return const Center(child: Icon(Icons.error_outline));
            }
            return ListView.builder(
              // Use ListView.builder for efficiency
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = snapshot.data!.docs[index];
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String content = data['content'] ?? '';
                Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
                DateTime dateTime = timestamp.toDate();
                String formattedTime =
                    DateFormat('MMM d, h:mm a').format(dateTime);
                String uid = data['uid'] ?? '';

                return Container(
                  color: XDarkThemeColors.secondaryBackground,
                  margin: const EdgeInsets.only(bottom: 5),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<DocumentSnapshot?>(
                              future: getUserData(uid),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircleAvatar(); // Placeholder
                                }

                                if (userSnapshot.hasError ||
                                    !userSnapshot.hasData ||
                                    userSnapshot.data?.data() == null) {
                                  return const CircleAvatar(
                                      child: Icon(Icons.error));
                                }

                                final userData = userSnapshot.data!.data()
                                    as Map<String, dynamic>;
                                final profileImageUrl =
                                    userData['profileImage'] as String?;

                                return CircleAvatar(
                                  backgroundImage: profileImageUrl != null
                                      ? NetworkImage(profileImageUrl)
                                      : null,
                                  child: profileImageUrl == null
                                      ? const Icon(Icons.person)
                                      : null,
                                );
                              },
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              // Added Expanded for better layout
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FutureBuilder<DocumentSnapshot?>(
                                    future: getUserData(uid),
                                    builder: (context, userSnapshot) {
                                      if (userSnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Text('Loading...',
                                            style:
                                                TextStyle(color: Colors.grey));
                                      }

                                      if (userSnapshot.hasError ||
                                          !userSnapshot.hasData ||
                                          userSnapshot.data?.data() == null) {
                                        return Text('Unknown User',
                                            style:
                                                TextStyle(color: Colors.grey));
                                      }

                                      final userData = userSnapshot.data!.data()
                                          as Map<String, dynamic>;
                                      final username =
                                          userData['name'] ?? 'No Username';

                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PostDetailScreen(
                                                userName: username,
                                                content: content,
                                                date: formattedTime,
                                              ), // Pass username
                                            ),
                                          );
                                        },
                                        child: Text('$username',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Text(content,
                                      style: TextStyle(
                                          color: XDarkThemeColors.primaryText)),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: <Widget>[
                                      Icon(AntDesign.comment_outline,
                                          color:
                                              XDarkThemeColors.mutedIconColor),
                                      SizedBox(width: 16),
                                      Icon(
                                        AntDesign.heart_outline,
                                        color: XDarkThemeColors.mutedIconColor,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(formattedTime,
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12)),
                                  // Add more post details and styling here
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey[900],
                        thickness: 2,
                        height: 5,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
