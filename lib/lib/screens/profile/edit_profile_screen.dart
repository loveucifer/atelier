import 'dart:io';
import 'package:atelier/main.dart';
import 'package:atelier/widgets/common/breathing_gradient_background.dart';
import 'package:atelier/widgets/common/glass_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isLoading = false;
  XFile? _selectedImage;
  String? _currentAvatarUrl;

  late final Future<void> _loadProfileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfileFuture = _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final data = await supabase.from('profiles').select().eq('id', userId).single();
      if (mounted) {
        setState(() {
          _displayNameController.text = data['display_name'] ?? '';
          _usernameController.text = data['username'] ?? '';
          _bioController.text = data['bio'] ?? '';
          _currentAvatarUrl = data['avatar_url'];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading profile data: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; });

    try {
      final user = supabase.auth.currentUser!;
      String? newAvatarUrl = _currentAvatarUrl;

      if (_selectedImage != null) {
        final imageFile = File(_selectedImage!.path);
        final fileExt = _selectedImage!.path.split('.').last;
        final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
        final filePath = '${user.id}/$fileName';

        if (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty) {
           final oldPathWithFolder = Uri.parse(_currentAvatarUrl!).pathSegments.sublist(2).join('/');
          try {
            await supabase.storage.from('avatars').remove([oldPathWithFolder]);
          } catch (e) {
            print("Error deleting old avatar: $e");
          }
        }

        await supabase.storage.from('avatars').upload(filePath, imageFile);
        newAvatarUrl = supabase.storage.from('avatars').getPublicUrl(filePath);
      }

      final updates = {
        'display_name': _displayNameController.text.trim(),
        'bio': _bioController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
        'avatar_url': newAvatarUrl,
      };

      await supabase.from('profiles').update(updates).eq('id', user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved!')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving profile: $e'), backgroundColor: Colors.red));
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BreathingGradientBackground(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: const GlassAppBar(title: 'Edit Profile'),
        body: FutureBuilder(
          future: _loadProfileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && _displayNameController.text.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.only(top: 120, left: 16, right: 16, bottom: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white10,
                            backgroundImage: _selectedImage != null
                                ? FileImage(File(_selectedImage!.path))
                                : (_currentAvatarUrl != null ? CachedNetworkImageProvider(_currentAvatarUrl!) : null)
                                    as ImageProvider?,
                            child: _selectedImage == null && _currentAvatarUrl == null
                                ? const Icon(CupertinoIcons.person_fill, size: 60, color: Colors.white54)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: const Icon(Icons.edit, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _displayNameController,
                      decoration: const InputDecoration(labelText: 'Display Name'),
                      validator: (value) =>
                          value!.isEmpty ? 'Display name cannot be empty' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'Username (cannot be changed)'),
                      readOnly: true,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(labelText: 'Bio'),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 32),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _saveProfile,
                            child: const Text('Save Changes'),
                          ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}