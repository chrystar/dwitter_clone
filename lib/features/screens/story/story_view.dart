import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';
import 'package:provider/provider.dart';
import '../../../providers/stories_provider.dart';
import '../../../theme/app_theme.dart';

class StoryViewScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const StoryViewScreen({
    Key? key,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  final StoryController controller = StoryController();
  List<StoryItem> storyItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    final storyProvider = Provider.of<StoryProvider>(context, listen: false);
    final stories = storyProvider.userStories[widget.userId] ?? [];

    for (final story in stories) {
      if (story.mediaType == 'image') {
        storyItems.add(
          StoryItem.pageImage(
            url: story.imageUrl,
            controller: controller,
            caption: Text("Posted ${_getTimeAgo(story.createdAt)}"),
          ),
        );
      } else if (story.mediaType == 'video') {
        storyItems.add(
          StoryItem.pageVideo(
            story.videoUrl,
            controller: controller,
            caption: Text("Posted ${_getTimeAgo(story.createdAt)}"),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : storyItems.isEmpty
              ? Center(
                  child: Text(
                    'No stories available',
                    style: TextStyle(color: XDarkThemeColors.primaryText),
                  ),
                )
              : Stack(
                  children: [
                    StoryView(
                      storyItems: storyItems,
                      controller: controller,
                      onComplete: () => Navigator.pop(context),
                      onVerticalSwipeComplete: (direction) {
                        if (direction == Direction.down) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 10,
                      left: 10,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[800],
                            child: Text(
                              widget.userName[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            widget.userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
