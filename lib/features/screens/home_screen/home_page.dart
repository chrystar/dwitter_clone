import 'package:dwitter_clone/features/screens/comment/comment_screen.dart';
import 'package:dwitter_clone/features/screens/post/create_post_screen.dart';
import 'package:dwitter_clone/providers/like_provider.dart';
import 'package:dwitter_clone/providers/stories_provider.dart';
import 'package:dwitter_clone/providers/viewed_stories_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:dwitter_clone/features/screens/profile/profile_screen.dart';
import 'widgets/story_ring.dart';

import '../../../theme/app_theme.dart';
import '../post/post_detail_screen.dart';
import '../story/story_view_screen.dart';
import '../story/create_story_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class _HomePageState extends State<HomePage> {
  User? user = _auth.currentUser;

  @override
  void initState() {
    super.initState();
    _initializeStories();
  }

  Future<void> _initializeStories() async {
    final storyProvider = Provider.of<StoryProvider>(context, listen: false);
    final viewedStoriesProvider =
        Provider.of<ViewedStoriesProvider>(context, listen: false);
    await Future.wait([
      storyProvider.fetchStoriesForFollowedUsers(),
      viewedStoriesProvider.loadViewedStories(),
    ]);
    await storyProvider.deleteExpiredStories();
  }

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

  Widget _buildStoryAvatar({
    required String userId,
    required String userName,
    String? profileImage,
    bool isCurrentUser = false,
  }) {
    final storyProvider = Provider.of<StoryProvider>(context);
    final viewedStoriesProvider = Provider.of<ViewedStoriesProvider>(context);
    final stories = storyProvider.userStories[userId] ?? [];
    final hasUnviewedStories = stories.isNotEmpty &&
        viewedStoriesProvider.hasUnviewedStories(userId,
            stories.map((s) => s.userId + s.createdAt.toString()).toList());

    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        children: [
          GestureDetector(
            onTap: isCurrentUser
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateStoryScreen(),
                      ),
                    );
                  }
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoryViewScreen(
                          userId: userId,
                          userName: userName,
                        ),
                      ),
                    );
                  },
            child: StoryRing(
              hasUnviewedStories: isCurrentUser ? false : hasUnviewedStories,
              child: CircleAvatar(
                radius: 28,
                backgroundColor: XDarkThemeColors.secondaryBackground,
                backgroundImage:
                    profileImage != null ? NetworkImage(profileImage) : null,
                child: profileImage == null
                    ? Icon(
                        isCurrentUser ? Icons.add : Icons.person,
                        color: isCurrentUser ? Colors.blue : Colors.grey,
                      )
                    : null,
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            isCurrentUser
                ? 'Your Story'
                : userName.length > 10
                    ? '${userName.substring(0, 10)}...'
                    : userName,
            style: TextStyle(
              color: XDarkThemeColors.primaryText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateStoryAvatar(User? currentUser) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: _buildStoryAvatar(
        userId: currentUser?.uid ?? '',
        userName: 'Your Story',
        isCurrentUser: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final likeProvider = Provider.of<LikeProvider>(context);
    final currentUser = _auth.currentUser;

    return Scaffold(
      backgroundColor: XDarkThemeColors.secondaryBackground,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 20),
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreatePostScreen(),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(50 / 2)),
            height: 50,
            width: 50,
            child: Icon(
              AntDesign.plus_outline,
              color: XDarkThemeColors.iconColor,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Section
            Container(
              height: 100,
              margin: EdgeInsets.only(top: 10),
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(currentUser?.uid)
                    .collection('following')
                    .snapshots(),
                builder: (context, followingSnapshot) {
                  if (followingSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!followingSnapshot.hasData ||
                      followingSnapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text('Follow people to see their status updates',
                          style: TextStyle(color: Colors.grey)),
                    );
                  }

                  List<String> followingIds = followingSnapshot.data!.docs
                      .map((doc) => doc.id)
                      .toList();

                  // Get StoryProvider to check for stories
                  final storyProvider = Provider.of<StoryProvider>(context);

                  // Filter out users without stories
                  final usersWithStories = [
                    if (storyProvider
                            .userStories[currentUser?.uid]?.isNotEmpty ??
                        false)
                      currentUser?.uid,
                    ...followingIds.where((id) =>
                        storyProvider.userStories[id]?.isNotEmpty ?? false)
                  ].whereType<String>().toList();

                  if (usersWithStories.isEmpty) {
                    return _buildCreateStoryAvatar(currentUser);
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: usersWithStories.length +
                        1, // +1 for create story button
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildCreateStoryAvatar(currentUser);
                      }

                      final userId = usersWithStories[index - 1];
                      return FutureBuilder<DocumentSnapshot<Object?>>(
                        future:
                            getUserData(userId).then((snapshot) => snapshot!),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return SizedBox.shrink();
                          }

                          final userData =
                              userSnapshot.data!.data() as Map<String, dynamic>;
                          final userName = userData['name'] ?? 'User';
                          final profileImage = userData['profileImage'];

                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: _buildStoryAvatar(
                              userId: userId,
                              userName: userName,
                              profileImage: profileImage,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            // Posts List
            StreamBuilder(
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
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = snapshot.data!.docs[index];
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    String content = data['content'] ?? '';
                    Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
                    String formattedTime =
                        DateFormat('MMM d, h:mm a').format(timestamp.toDate());
                    String uid = data['uid'] ?? '';
                    String postId = document.id;
                    List<String> likes = List<String>.from(data['likes'] ?? []);

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
                                      return const CircleAvatar();
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

                                    return GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProfileScreen(userId: uid),
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        backgroundImage: profileImageUrl != null
                                            ? NetworkImage(profileImageUrl)
                                            : null,
                                        child: profileImageUrl == null
                                            ? const Icon(Icons.person)
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FutureBuilder<DocumentSnapshot?>(
                                        future: getUserData(uid),
                                        builder: (context, userSnapshot) {
                                          if (userSnapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Text('Loading...',
                                                style: TextStyle(
                                                    color: Colors.grey));
                                          }

                                          if (userSnapshot.hasError ||
                                              !userSnapshot.hasData ||
                                              userSnapshot.data?.data() ==
                                                  null) {
                                            return Text('Unknown User',
                                                style: TextStyle(
                                                    color: Colors.grey));
                                          }

                                          final userData = userSnapshot.data!
                                              .data() as Map<String, dynamic>;
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
                                                    postId: postId,
                                                    date: timestamp,
                                                    userId: uid,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Text(username,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      Text(content,
                                          style: TextStyle(
                                              color: XDarkThemeColors
                                                  .primaryText)),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: <Widget>[
                                          IconButton(
                                            onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CommentScreen(
                                                  postId: postId,
                                                ),
                                              ),
                                            ),
                                            icon:
                                                Icon(AntDesign.comment_outline),
                                            color:
                                                XDarkThemeColors.mutedIconColor,
                                          ),
                                          SizedBox(width: 16),
                                          Row(
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  if (currentUser != null) {
                                                    likeProvider
                                                        .togglePostLike(postId);
                                                  }
                                                },
                                                icon: Icon(
                                                  likes.contains(
                                                          currentUser?.uid)
                                                      ? AntDesign.heart_fill
                                                      : AntDesign.heart_outline,
                                                  color: likes.contains(
                                                          currentUser?.uid)
                                                      ? Colors.red
                                                      : XDarkThemeColors
                                                          .mutedIconColor,
                                                ),
                                              ),
                                              Text(
                                                likes.length.toString(),
                                                style: TextStyle(
                                                  color: XDarkThemeColors
                                                      .mutedIconColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(formattedTime,
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: XDarkThemeColors.divider,
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
          ],
        ),
      ),
    );
  }
}
