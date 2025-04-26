import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dwitter_clone/features/screens/comment/comment_screen.dart';
import 'package:dwitter_clone/providers/comment_provider.dart';
import 'package:dwitter_clone/providers/follow_provider.dart';
import 'package:dwitter_clone/providers/like_provider.dart';
import 'package:dwitter_clone/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/comment_model.dart';

class PostDetailScreen extends StatefulWidget {
  final String userName;
  final String content;
  final dynamic date;
  final String postId;
  final String userId; // Add userId parameter

  const PostDetailScreen({
    super.key,
    required this.userName,
    required this.content,
    required this.date,
    required this.postId,
    required this.userId, // Add this parameter
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Future<bool> _isFollowingFuture;

  @override
  void initState() {
    super.initState();
    _isFollowingFuture =
        context.read<FollowProvider>().isFollowing(widget.userId);
  }

  String formatDate(dynamic date) {
    if (date is Timestamp) {
      return DateFormat('MMM d, h:mm a').format(date.toDate());
    } else if (date is String) {
      try {
        return DateFormat('MMM d, h:mm a').format(DateTime.parse(date));
      } catch (e) {
        // If parsing fails, return a default format
        return DateFormat('MMM d, h:mm a').format(DateTime.now());
      }
    } else {
      return DateFormat('MMM d, h:mm a').format(DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentProvider = Provider.of<CommentProvider>(context);
    final followProvider = Provider.of<FollowProvider>(context);
    final likeProvider = Provider.of<LikeProvider>(context);
    final currentUser = FirebaseAuth.instance.currentUser;
    final isCurrentUser = currentUser?.uid == widget.userId;

    return Scaffold(
      backgroundColor: XDarkThemeColors.secondaryBackground,
      appBar: AppBar(
        backgroundColor: XDarkThemeColors.secondaryBackground,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(AntDesign.arrow_left_outline),
          color: XDarkThemeColors.iconColor,
        ),
        title: const Text(
          'Post',
          style: TextStyle(
            color: XDarkThemeColors.primaryText,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: likeProvider.getPostLikes(widget.postId),
        builder: (context, likesSnapshot) {
          final List<String> likes = likesSnapshot.hasData
              ? List<String>.from(likesSnapshot.data?['likes'] ?? [])
              : [];

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: XDarkThemeColors.mutedIconColor,
                          child: Text(
                            widget.userName[0].toUpperCase(),
                            style: const TextStyle(
                                color: XDarkThemeColors.primaryText),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.userName,
                              style: const TextStyle(
                                color: XDarkThemeColors.primaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              formatDate(widget.date),
                              style: TextStyle(
                                color: XDarkThemeColors.secondaryText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (!isCurrentUser) // Only show follow button if not current user
                      FutureBuilder<bool>(
                        future: _isFollowingFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(),
                            );
                          }

                          final isFollowing = snapshot.data ?? false;

                          return ElevatedButton(
                            onPressed: () async {
                              await followProvider.toggleFollow(widget.userId);
                              setState(() {
                                _isFollowingFuture =
                                    followProvider.isFollowing(widget.userId);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFollowing
                                  ? XDarkThemeColors.secondaryBackground
                                  : XDarkThemeColors.primaryAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: isFollowing
                                    ? const BorderSide(
                                        color: XDarkThemeColors.primaryAccent)
                                    : BorderSide.none,
                              ),
                            ),
                            child: Text(
                              isFollowing ? 'Following' : 'Follow',
                              style: TextStyle(
                                color: isFollowing
                                    ? XDarkThemeColors.primaryAccent
                                    : XDarkThemeColors.primaryText,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.content,
                  style: const TextStyle(
                    color: XDarkThemeColors.primaryText,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(
                  color: XDarkThemeColors.divider,
                  thickness: 1,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      _buildInteractionButton(
                        icon: likes.contains(currentUser?.uid)
                            ? AntDesign.heart_fill
                            : AntDesign.heart_outline,
                        text: likes.length.toString(),
                        onTap: () {
                          if (currentUser != null) {
                            likeProvider.togglePostLike(widget.postId);
                          }
                        },
                        iconColor: likes.contains(currentUser?.uid)
                            ? Colors.red
                            : XDarkThemeColors.mutedIconColor,
                      ),
                      const SizedBox(width: 24),
                      _buildInteractionButton(
                        icon: AntDesign.comment_outline,
                        text: 'Reply',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CommentScreen(postId: widget.postId),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: XDarkThemeColors.divider,
                  thickness: 1,
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .doc(widget.postId)
                        .collection('comments')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(
                                color: XDarkThemeColors.primaryText),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                AntDesign.comment_outline,
                                color: XDarkThemeColors.mutedIconColor,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No comments yet',
                                style: TextStyle(
                                  color: XDarkThemeColors.primaryText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CommentScreen(postId: widget.postId),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Start the conversation',
                                  style: TextStyle(
                                    color: XDarkThemeColors.primaryAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final doc = snapshot.data!.docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final comment = CommentModel.fromMap(data);

                          return FutureBuilder<String?>(
                            future:
                                commentProvider.getPosterUsername(comment.uid),
                            builder: (context, usernameSnapshot) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          XDarkThemeColors.mutedIconColor,
                                      child: Text(
                                        (usernameSnapshot.data ?? '?')[0]
                                            .toUpperCase(),
                                        style: const TextStyle(
                                            color:
                                                XDarkThemeColors.primaryText),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                usernameSnapshot.data ??
                                                    'Loading...',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: XDarkThemeColors
                                                      .primaryText,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                DateFormat('MMM d')
                                                    .format(comment.timestamp),
                                                style: const TextStyle(
                                                  color: XDarkThemeColors
                                                      .secondaryText,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            comment.content,
                                            style: const TextStyle(
                                              color:
                                                  XDarkThemeColors.primaryText,
                                            ),
                                          ),
                                          if (comment.imageUrl != null) ...[
                                            const SizedBox(height: 8),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.network(
                                                comment.imageUrl!,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              _buildInteractionButton(
                                                icon: Icons.favorite_border,
                                                text: comment.likes.length
                                                    .toString(),
                                                onTap: () {
                                                  // TODO: Implement like functionality
                                                },
                                                iconSize: 16,
                                                textStyle: const TextStyle(
                                                  color: XDarkThemeColors
                                                      .secondaryText,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              if (comment.uid ==
                                                  currentUser?.uid)
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                    size: 16,
                                                    color: XDarkThemeColors
                                                        .mutedIconColor,
                                                  ),
                                                  onPressed: () async {
                                                    try {
                                                      await commentProvider
                                                          .deleteComment(
                                                        widget.postId,
                                                        doc.id,
                                                      );
                                                    } catch (e) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              'Failed to delete comment: $e'),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CommentScreen(postId: widget.postId),
            ),
          );
        },
        backgroundColor: XDarkThemeColors.primaryAccent,
        child: const Icon(Icons.comment_outlined),
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    double iconSize = 20,
    TextStyle? textStyle,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor ?? XDarkThemeColors.mutedIconColor,
            size: iconSize,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: textStyle ??
                const TextStyle(
                  color: XDarkThemeColors.primaryText,
                  fontSize: 14,
                ),
          ),
        ],
      ),
    );
  }
}
