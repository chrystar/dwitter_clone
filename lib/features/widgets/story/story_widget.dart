import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dwitter_clone/features/screens/story/story_view_screen.dart';
import 'package:dwitter_clone/features/screens/home_screen/widgets/story_ring.dart';
import 'package:dwitter_clone/providers/stories_provider.dart';
import 'package:dwitter_clone/providers/viewed_stories_provider.dart';
import 'package:dwitter_clone/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class StoryWidget extends StatelessWidget {
  const StoryWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final storyProvider = Provider.of<StoryProvider>(context);

    return Container(
      height: 100,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: StreamBuilder<QuerySnapshot>(
        stream: storyProvider.getStories(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final stories = snapshot.data?.docs ?? [];

          if (stories.isEmpty && storyProvider.canCreateStory()) {
            return Center(child: CreateStoryButton());
          }

          return ListView(
            scrollDirection: Axis.horizontal,
            children: [
              if (storyProvider.canCreateStory())
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: CreateStoryButton(),
                ),
              ...stories.map((doc) {
                final storyData = doc.data() as Map<String, dynamic>;
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(storyData['userId'])
                      .get(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return const SizedBox(width: 80);
                    }

                    final userData =
                        userSnapshot.data?.data() as Map<String, dynamic>?;
                    if (userData == null) return const SizedBox(width: 80);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StoryViewScreen(
                              userId: storyData['userId'],
                              userName: userData['name'] ?? 'Unknown',
                            ),
                          ),
                        );
                      },
                      child: StoryItem(
                        userId: storyData['userId'],
                        imageUrl: storyData['imageUrl'] ?? '',
                        timestamp:
                            (storyData['createdAt'] as Timestamp).toDate(),
                        username: userData['name'] ?? 'Unknown',
                        profileImage: userData['profileImage'] ?? '',
                      ),
                    );
                  },
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}

class CreateStoryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final ImagePicker picker = ImagePicker();
        final XFile? image =
            await picker.pickImage(source: ImageSource.gallery);

        if (image != null && context.mounted) {
          final storyProvider =
              Provider.of<StoryProvider>(context, listen: false);
          await storyProvider.uploadStory(image.path, null, context);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: XDarkThemeColors.primaryAccent,
            ),
            child: Icon(Icons.add, color: Colors.white, size: 30),
          ),
          SizedBox(height: 4),
          Text(
            'Add Story',
            style: TextStyle(
              color: XDarkThemeColors.primaryText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class StoryItem extends StatelessWidget {
  final String userId;
  final String imageUrl;
  final DateTime timestamp;
  final String username;
  final String profileImage;

  const StoryItem({
    Key? key,
    required this.userId,
    required this.imageUrl,
    required this.timestamp,
    required this.username,
    required this.profileImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Consumer<ViewedStoriesProvider>(
            builder: (context, viewedStoriesProvider, _) {
              return StoryRing(
                hasUnviewedStories: viewedStoriesProvider.hasUnviewedStories(
                  userId,
                  [userId + timestamp.toString()],
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.black,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: profileImage.isNotEmpty
                        ? NetworkImage(profileImage)
                        : null,
                    child: profileImage.isEmpty
                        ? Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 4),
          Text(
            username,
            style: TextStyle(
              color: XDarkThemeColors.primaryText,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
