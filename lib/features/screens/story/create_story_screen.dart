import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../providers/stories_provider.dart';
import '../../../theme/app_theme.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({Key? key}) : super(key: key);

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final TextEditingController _textController = TextEditingController();
  XFile? _selectedMedia;
  bool isLoading = false;
  String? _errorMessage;
  Color _backgroundColor = Colors.black;
  bool _isVideo = false;
  String _mediaType = 'text'; // 'text', 'image', or 'video'

  final List<Color> _colorOptions = [
    Colors.black,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _shareStory() async {
    if (_textController.text.isNotEmpty) {
      await Share.share(_textController.text);
    }
  }

  Future<void> _pickMedia(ImageSource source, bool isVideo) async {
    final picker = ImagePicker();
    final media = isVideo
        ? await picker.pickVideo(source: source)
        : await picker.pickImage(source: source);

    if (media != null) {
      setState(() {
        _selectedMedia = media;
        _isVideo = isVideo;
        _mediaType = isVideo ? 'video' : 'image';
        _textController.clear();
      });
    }
  }

  Future<void> _createStory() async {
    if (_textController.text.trim().isEmpty && _selectedMedia == null) {
      setState(() {
        _errorMessage = "Please add text or select an image for your story";
      });
      return;
    }

    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    try {
      final storyProvider = Provider.of<StoryProvider>(context, listen: false);

      if (_selectedMedia != null) {
        await storyProvider.uploadStory(
          _selectedMedia!.path,
          null,
          context,
        );
      } else {
        await storyProvider.uploadTextStory(
          _textController.text.trim(),
          context,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      setState(() {
        _errorMessage = "Failed to create story: $error";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasContent =
        _textController.text.trim().isNotEmpty || _selectedMedia != null;

    return Scaffold(
      backgroundColor: XDarkThemeColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: XDarkThemeColors.primaryBackground,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: XDarkThemeColors.iconColor),
        ),
        title: Text('Create Story',
            style: TextStyle(color: XDarkThemeColors.primaryText)),
        actions: [
          if (_mediaType == 'text')
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Select Background Color'),
                    content: Wrap(
                      spacing: 8,
                      children: _colorOptions.map((color) {
                        return InkWell(
                          onTap: () {
                            setState(() => _backgroundColor = color);
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
              icon:
                  Icon(Icons.color_lens, color: XDarkThemeColors.primaryAccent),
            ),
          if (_mediaType == 'text' &&
              _textController.text.trim().isNotEmpty) // Modified condition
            IconButton(
              onPressed: _shareStory,
              icon: Icon(Icons.share, color: XDarkThemeColors.primaryAccent),
            ),
          if (hasContent)
            TextButton(
              onPressed: isLoading ? null : _createStory,
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            XDarkThemeColors.primaryAccent),
                      ),
                    )
                  : Text(
                      'Share',
                      style: TextStyle(
                        color: XDarkThemeColors.primaryAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              if (_selectedMedia == null)
                Container(
                  color: _backgroundColor,
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    style: TextStyle(
                      color: XDarkThemeColors.primaryText,
                      fontSize: 24,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type your story...',
                      hintStyle: TextStyle(
                        color: XDarkThemeColors.secondaryText,
                        fontSize: 24,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                )
              else
                Stack(
                  children: [
                    _isVideo
                        ? Center(child: Icon(Icons.play_circle_fill, size: 50))
                        : Image.network(
                            _selectedMedia!.path,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 400,
                          ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _selectedMedia = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: XDarkThemeColors.primaryBackground,
        selectedItemColor: XDarkThemeColors.primaryAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _mediaType == 'text'
            ? 0
            : _mediaType == 'image'
                ? 1
                : 2,
        onTap: (index) {
          setState(() {
            switch (index) {
              case 0:
                _mediaType = 'text';
                _selectedMedia = null;
                _isVideo = false;
                break;
              case 1:
                _mediaType = 'image';
                _pickMedia(ImageSource.gallery, false);
                break;
              case 2:
                _mediaType = 'video';
                _pickMedia(ImageSource.gallery, true);
                break;
            }
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.text_fields),
            label: 'Text',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Photo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videocam),
            label: 'Video',
          ),
        ],
      ),
    );
  }
}
