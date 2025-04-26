import 'dart:io';

import 'package:dwitter_clone/providers/post_provider.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_theme.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

XFile? _selectedImage;
final ImagePicker picker = ImagePicker();

Future<XFile?> multipleImage() async {
  List<XFile> getMultipleImage = await picker.pickMultiImage();
  if (getMultipleImage != null && getMultipleImage.isNotEmpty) {
    print('object');
  }
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  Future<XFile?> singleImage() async {
    final getImage = await picker.pickImage(source: ImageSource.gallery);
    if (getImage != null) {
      setState(() {
        _selectedImage = getImage;
      });
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  final TextEditingController _contentController = TextEditingController();
  bool isLoading = false;
  String? _errorMessage;

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "Post content cannot be empty.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    try {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      await postProvider.createPost(
        _contentController.text.trim(),
      );
      // Optionally clear the text and image after successful post
      setState(() {
        _contentController.clear();
        _selectedImage = null;
      });
      Navigator.pop(context); // Go back after posting
    } catch (error) {
      setState(() {
        isLoading = false;
        _errorMessage = "Failed to create post: $error";
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
    //final postProvider = Provider.of<PostProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: XDarkThemeColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: XDarkThemeColors.primaryBackground,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.cancel_outlined, color: XDarkThemeColors.iconColor,),
        ),
        actions: [
          GestureDetector(
            onTap: () => _createPost(),
            child: Container(
              margin: EdgeInsets.only(right: 20),
              padding: EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 8),
              decoration: BoxDecoration(
                  color: _contentController.text.trim().isEmpty ? Colors.blue.shade200 : XDarkThemeColors.primaryAccent,
                  borderRadius: BorderRadius.circular(20)),
              child: isLoading == false
                  ? Text(
                      'Post',
                      style: TextStyle(color: Colors.white),
                    )
                  : Center(
                      child: CircularProgressIndicator(
                      color: Colors.grey,
                    )),
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(left: 20, top: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(),
                SizedBox(width: 10),
                Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 5, bottom: 5),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: XDarkThemeColors.primaryAccent),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Everyone',
                            style: TextStyle(
                                color: XDarkThemeColors.primaryAccent),
                          ),
                          Icon(Icons.keyboard_arrow_down_rounded),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: TextFormField(
                    maxLines: null,
                    onChanged: (value) {
                      setState(() {
                        _errorMessage = null; // Clear error message on typing
                      });
                    },
                    controller: _contentController,
                    keyboardType: TextInputType.multiline,
                    autofocus: true,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20
                    ),
                    decoration: InputDecoration(
                      hintText: _selectedImage != null
                          ? "Add a comment"
                          : "What's happening",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                      ),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  child: _selectedImage == null
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Expanded(
                            child: Stack(
                              children: [
                                Container(
                                  height: 200,
                                  margin: EdgeInsets.only(bottom: 120),
                                  width: double.infinity,

                                  // child: Image.file(
                                  //   File(_selectedImage!.path),
                                  //   fit: BoxFit.cover,
                                  // ),
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: FileImage(
                                        File(_selectedImage!.path),
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: Icon(Icons.cancel),
                                    color: Colors.white,
                                    onPressed: _clearImage,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
          _selectedImage == null
              ? SizedBox(
                  child: Expanded(
                    child: GestureDetector(
                      onTap: () {
                        singleImage();
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(20)),
                        height: 80,
                        width: 80,
                        child: Center(
                          child: Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.blue.shade200,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
          Container(
            child: Column(
              children: [
                Divider(
                  color: Colors.grey.shade300,
                  thickness: 1,
                  height: 5,
                ),
                Container(
                  padding: EdgeInsets.only(left: 8, bottom: 16, top: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.my_location_outlined,
                        color: XDarkThemeColors.primaryAccent,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Everyone can reply',
                        style: TextStyle(
                          color: XDarkThemeColors.primaryAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.grey.shade300,
                  thickness: 1,
                  height: 5,
                ),
                Container(
                  padding: EdgeInsets.only(left: 8, bottom: 16, top: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.image,
                        color: XDarkThemeColors.primaryAccent,
                      ),
                      SizedBox(width: 30),
                      Icon(
                        Icons.gif_box_outlined,
                        color: XDarkThemeColors.primaryAccent,
                      ),
                      SizedBox(width: 30),
                      Icon(
                        Icons.share,
                        color: XDarkThemeColors.primaryAccent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
