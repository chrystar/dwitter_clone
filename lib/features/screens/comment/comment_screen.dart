import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dwitter_clone/models/comment_model.dart';
import 'package:dwitter_clone/providers/comment_provider.dart';
import 'package:dwitter_clone/providers/like_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_theme.dart';

class CommentScreen extends StatefulWidget {
  final String postId;
  const CommentScreen({super.key, required this.postId});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  XFile? _selectedImage;
  final ImagePicker picker = ImagePicker();
  final TextEditingController _contentController = TextEditingController();
  bool isLoading = false;
  String? _errorMessage;
  final _auth = FirebaseAuth.instance;

  Future<XFile?> singleImage() async {
    final getImage = await picker.pickImage(source: ImageSource.gallery);
    if (getImage != null) {
      setState(() {
        _selectedImage = getImage;
      });
    }
    return getImage;
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _createComment() async {
    if (_contentController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "Comment cannot be empty.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final commentProvider =
          Provider.of<CommentProvider>(context, listen: false);
      await commentProvider.addComment(
        user.uid,
        widget.postId,
        _contentController.text.trim(),
      );

      setState(() {
        _contentController.clear();
        _selectedImage = null;
      });
      Navigator.pop(context);
    } catch (error) {
      setState(() {
        _errorMessage = "Failed to post comment: $error";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentProvider = Provider.of<CommentProvider>(context);
    final likeProvider = Provider.of<LikeProvider>(context);
    final currentUser = _auth.currentUser;

    return Scaffold(
      backgroundColor: XDarkThemeColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: XDarkThemeColors.primaryBackground,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: XDarkThemeColors.iconColor),
        ),
        title: Text('Reply',
            style: TextStyle(color: XDarkThemeColors.primaryText)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: _contentController.text.trim().isEmpty
                  ? null
                  : _createComment,
              style: ElevatedButton.styleFrom(
                backgroundColor: XDarkThemeColors.primaryAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text('Reply'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.postId)
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No comments yet'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final comment = CommentModel.fromMap(data);
                    if (comment.postId != widget.postId) {
                      return const SizedBox.shrink();
                    }

                    return FutureBuilder<String?>(
                      future: commentProvider.getPosterUsername(comment.uid),
                      builder: (context, usernameSnapshot) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    XDarkThemeColors.mutedIconColor,
                                child: Text(
                                  (usernameSnapshot.data ?? '?')[0]
                                      .toUpperCase(),
                                  style: TextStyle(
                                      color: XDarkThemeColors.primaryText),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          usernameSnapshot.data ?? 'Loading...',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: XDarkThemeColors.primaryText,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          DateFormat('MMM d')
                                              .format(comment.timestamp)
                                              .toString(),
                                          style: TextStyle(
                                            color:
                                                XDarkThemeColors.secondaryText,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      comment.content,
                                      style: TextStyle(
                                          color: XDarkThemeColors.primaryText),
                                    ),
                                    if (comment.imageUrl != null) ...[
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          comment.imageUrl!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            comment.likes
                                                    .contains(currentUser?.uid)
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            size: 16,
                                            color: comment.likes
                                                    .contains(currentUser?.uid)
                                                ? Colors.red
                                                : XDarkThemeColors
                                                    .mutedIconColor,
                                          ),
                                          onPressed: () {
                                            if (currentUser != null) {
                                              likeProvider.toggleCommentLike(
                                                widget.postId,
                                                doc.id,
                                              );
                                            }
                                          },
                                        ),
                                        Text(
                                          comment.likes.length.toString(),
                                          style: TextStyle(
                                            color:
                                                XDarkThemeColors.secondaryText,
                                          ),
                                        ),
                                        if (comment.uid == currentUser?.uid)
                                          IconButton(
                                            icon: Icon(
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
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          'Failed to delete comment: $e')),
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
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: XDarkThemeColors.divider, width: 0.5),
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: XDarkThemeColors.mutedIconColor,
                  child: Text(
                    (currentUser?.email?[0] ?? '?').toUpperCase(),
                    style: TextStyle(color: XDarkThemeColors.primaryText),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      hintText: 'Post your reply',
                      hintStyle:
                          TextStyle(color: XDarkThemeColors.secondaryText),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(color: XDarkThemeColors.primaryText),
                    maxLines: null,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.image_outlined,
                    color: XDarkThemeColors.primaryAccent,
                  ),
                  onPressed: singleImage,
                ),
              ],
            ),
          ),
          if (_selectedImage != null)
            Container(
              padding: const EdgeInsets.all(16.0),
              height: 120,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_selectedImage!.path),
                      fit: BoxFit.cover,
                      height: 120,
                      width: 120,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: Icon(Icons.close,
                          color: XDarkThemeColors.primaryText),
                      onPressed: _clearImage,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
