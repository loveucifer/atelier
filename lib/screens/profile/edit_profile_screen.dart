import 'dart:io';
import 'package:atelier/main.dart';
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

  // Logic to load existing profile data is preserved.
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

  // Logic to pick a new image is preserved.
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  // Logic to save the profile, including deleting the old photo, is preserved.
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; });

    try {
      final user = supabase.auth.currentUser!;
      String? newAvatarUrl = _currentAvatarUrl;

      // Check if a new image has been selected.
      if (_selectedImage != null) {
        final imageFile = File(_selectedImage!.path);
        final fileExt = _selectedImage!.path.split('.').last;
        final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
        final filePath = '${user.id}/$fileName';

        // --- IMPORTANT: OLD PHOTO DELETION LOGIC ---
        // If a current avatar exists, delete it from storage first.
        if (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty) {
          try {
            final uri = Uri.parse(_currentAvatarUrl!);
            final pathSegments = uri.pathSegments;
            // Find the bucket name in the path to robustly get the file path
            final bucketIndex = pathSegments.indexOf('avatars'); 
            if (bucketIndex != -1) {
              final oldFilePath = pathSegments.sublist(bucketIndex + 1).join('/');
              await supabase.storage.from('avatars').remove([oldFilePath]);
            }
          } catch (e) {
            // Optional: Log error if old avatar deletion fails, but don't block update.
            // ignore: avoid_print
            print("Error deleting old avatar: $e");
          }
        }
        // --- END OF DELETION LOGIC ---

        // Upload the new image.
        await supabase.storage.from('avatars').upload(filePath, imageFile);
        newAvatarUrl = supabase.storage.from('avatars').getPublicUrl(filePath);
      }

      final updates = {
        'display_name': _displayNameController.text.trim(),
        'bio': _bioController.text.trim(),
        'avatar_url': newAvatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
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
    // New UI with standard Scaffold and AppBar.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          // Show a loading indicator in the AppBar while saving.
          _isLoading 
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5))
              )
            : TextButton(
              onPressed: _saveProfile,
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            )
        ],
      ),
      body: FutureBuilder(
        future: _loadProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _displayNameController.text.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                   const SizedBox(height: 20),
                  // New avatar picker style.
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Theme.of(context).inputDecorationTheme.fillColor,
                      backgroundImage: _selectedImage != null
                          ? FileImage(File(_selectedImage!.path))
                          : (_currentAvatarUrl != null ? CachedNetworkImageProvider(_currentAvatarUrl!) : null)
                              as ImageProvider?,
                      child: _selectedImage == null && _currentAvatarUrl == null
                          ? Icon(CupertinoIcons.person_fill, size: 60, color: Colors.grey.shade400)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                   Text('Tap to change photo', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                  const SizedBox(height: 32),
                  // Form fields use the new theme automatically.
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
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bioController,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      alignLabelWithHint: true, // Better for multi-line fields.
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}