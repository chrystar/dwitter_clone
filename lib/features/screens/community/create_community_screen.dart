import 'package:dwitter_clone/providers/community_provider.dart';
import 'package:dwitter_clone/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'Technology';
  XFile? _avatarImage;
  XFile? _bannerImage;
  bool _isLoading = false;

  List<String> categories = [
    'Technology',
    'Gaming',
    'Sports',
    'Entertainment',
    'Education',
    'Art',
    'Music',
    'Food',
    'Travel',
    'Other'
  ];

  Future<void> _pickImage(bool isAvatar) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isAvatar) {
          _avatarImage = image;
        } else {
          _bannerImage = image;
        }
      });
    }
  }

  Future<String?> _uploadImage(XFile image, String path) async {
    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('community_images')
          .child(path);

      await ref.putFile(File(image.path));
      return await ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
      return null;
    }
  }

  Future<void> _createCommunity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? avatarUrl;
      String? bannerUrl;

      if (_avatarImage != null) {
        avatarUrl = await _uploadImage(_avatarImage!,
            'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg');
      }

      if (_bannerImage != null) {
        bannerUrl = await _uploadImage(_bannerImage!,
            'banner_${DateTime.now().millisecondsSinceEpoch}.jpg');
      }

      await context.read<CommunityProvider>().createCommunity(
            name: _nameController.text,
            description: _descriptionController.text,
            category: _selectedCategory,
            avatarImage: avatarUrl,
            bannerImage: bannerUrl,
          );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create community: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: XDarkThemeColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: XDarkThemeColors.primaryBackground,
        leading: IconButton(
          icon: Icon(Icons.close, color: XDarkThemeColors.iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Create Community',
            style: TextStyle(color: XDarkThemeColors.primaryText)),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createCommunity,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          XDarkThemeColors.primaryAccent),
                    ),
                  )
                : Text('Create',
                    style: TextStyle(color: XDarkThemeColors.primaryAccent)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _pickImage(false),
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: XDarkThemeColors.secondaryBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _bannerImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_bannerImage!.path),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate,
                                      color: XDarkThemeColors.iconColor,
                                      size: 40),
                                  Text('Add Banner Image',
                                      style: TextStyle(
                                          color: XDarkThemeColors.primaryText)),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _pickImage(true),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: XDarkThemeColors.secondaryBackground,
                        backgroundImage: _avatarImage != null
                            ? FileImage(File(_avatarImage!.path))
                            : null,
                        child: _avatarImage == null
                            ? Icon(Icons.add_photo_alternate,
                                color: XDarkThemeColors.iconColor)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: XDarkThemeColors.primaryText),
                decoration: InputDecoration(
                  labelText: 'Community Name',
                  labelStyle: TextStyle(color: XDarkThemeColors.secondaryText),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: XDarkThemeColors.divider),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a community name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                style: TextStyle(color: XDarkThemeColors.primaryText),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: XDarkThemeColors.secondaryText),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: XDarkThemeColors.divider),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a community description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              Text('Category',
                  style: TextStyle(color: XDarkThemeColors.secondaryText)),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((category) {
                  return ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: XDarkThemeColors.primaryAccent,
                    backgroundColor: XDarkThemeColors.secondaryBackground,
                    labelStyle: TextStyle(
                      color: _selectedCategory == category
                          ? XDarkThemeColors.primaryText
                          : XDarkThemeColors.secondaryText,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
