import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.cancel),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 20),
            padding: EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 8),
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(20)),
            child: Text('Post'),
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
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Everyone',
                            style: TextStyle(color: Colors.blue),
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
                    keyboardType: TextInputType.multiline,
                    autofocus: true,
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
                          child: Icon(Icons.camera_alt_outlined, color: Colors.blue.shade200,),
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
                      Icon(Icons.my_location_outlined, color: Colors.blue,),
                      SizedBox(width: 10),
                      Text(
                        'Everyone can reply',
                        style: TextStyle(
                          color: Colors.blue,
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
                        color: Colors.blue,
                      ),
                      SizedBox(width: 30),
                      Icon(
                        Icons.gif_box_outlined,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 30),
                      Icon(
                        Icons.share,
                        color: Colors.blue,
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
