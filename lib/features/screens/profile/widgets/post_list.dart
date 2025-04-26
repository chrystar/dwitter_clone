import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/like_provider.dart';
import '../../../../theme/app_theme.dart';

class PostList extends StatelessWidget {
  const PostList({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProviders>(context).user;
    final likeProvider = Provider.of<LikeProvider>(context);

    if (user == null) {
      return const Center(child: Text('Please sign in to view posts'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: user.uid)
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.post_add,
                    size: 48, color: XDarkThemeColors.primaryText),
                const SizedBox(height: 16),
                Text(
                  'No posts yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: XDarkThemeColors.primaryText,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final post = snapshot.data!.docs[index];
            final data = post.data() as Map<String, dynamic>;
            final likes = List<String>.from(data['likes'] ?? []);

            return Card(
              color: XDarkThemeColors.secondaryBackground,
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: data['userProfileImage'] != null
                              ? NetworkImage(data['userProfileImage'])
                              : null,
                          radius: 20,
                          child: data['userProfileImage'] == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['userName'] ?? 'Unknown User',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: XDarkThemeColors.primaryText,
                              ),
                            ),
                            Text(
                              '@${data['userHandle'] ?? 'unknown'}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      data['content'] ?? '',
                      style: TextStyle(
                        color: XDarkThemeColors.primaryText,
                        fontSize: 16,
                      ),
                    ),
                    if (data['imageUrl'] != null) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          data['imageUrl'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInteractionButton(
                          icon: Icons.comment_outlined,
                          count: data['commentsCount'] ?? 0,
                        ),
                        _buildInteractionButton(
                          icon: Icons.repeat,
                          count: data['repostsCount'] ?? 0,
                        ),
                        _buildInteractionButton(
                          icon: likes.contains(user.uid)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          count: likes.length,
                          color: likes.contains(user.uid)
                              ? Colors.red
                              : Colors.grey,
                          onPressed: () => likeProvider.togglePostLike(post.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.share_outlined),
                          color: Colors.grey,
                          onPressed: () {
                            // TODO: Implement share functionality
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required int count,
    VoidCallback? onPressed,
    Color? color,
  }) {
    return Row(
      children: [
        IconButton(
          icon: Icon(icon),
          color: color ?? Colors.grey,
          onPressed: onPressed,
        ),
        Text(
          count.toString(),
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
