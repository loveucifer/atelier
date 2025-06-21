import 'dart:io';
import 'package:atelier/main.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  
  String _selectedCategory = 'Painting';
  String _selectedType = 'PRODUCT'; // Default to 'PRODUCT'
  bool _isLoading = false;
  XFile? _selectedImage;

  // --- Image Picking Logic (Unchanged) ---
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  // --- Submit Logic (Unchanged) ---
  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image for your listing.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User is not authenticated');

      final imageFile = File(_selectedImage!.path);
      final fileExt = _selectedImage!.path.split('.').last;
      final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
      final filePath = '${user.id}/$fileName';

      await supabase.storage.from('listing-media').upload(
            filePath,
            imageFile,
            fileOptions: FileOptions(contentType: _selectedImage!.mimeType),
          );

      final imageUrl = supabase.storage.from('listing-media').getPublicUrl(filePath);

      await supabase.from('listings').insert({
        'user_id': user.id,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price_guide': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'category': _selectedCategory,
        'type': _selectedType,
        'image_urls': [imageUrl],
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing created successfully!')),
        );
        Navigator.of(context).pop();
      }

    } catch (error) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: $error'),
            backgroundColor: Colors.red,
          ),
        );
       }
    }

    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Listing'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- New Image Picker UI with Dashed Border ---
              GestureDetector(
                onTap: _pickImage,
                child: DottedBorder(
                  color: Colors.grey,
                  strokeWidth: 2,
                  dashPattern: const [8, 4],
                  radius: const Radius.circular(12),
                  borderType: BorderType.RRect,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(_selectedImage!.path),
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.photo_on_rectangle, size: 40, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Add an Image', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // --- Updated Form Fields ---
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Listing Title'),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true),
                maxLines: 4,
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price Guide (e.g., 5000)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter a price' : null,
              ),
              const SizedBox(height: 24),
              
              // --- New Custom Toggle for Listing Type ---
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _selectedType = 'PRODUCT'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _selectedType == 'PRODUCT' ? Theme.of(context).primaryColor : Colors.transparent,
                        foregroundColor: _selectedType == 'PRODUCT' ? Colors.white : Theme.of(context).primaryColor,
                      ),
                      child: const Text('Product'),
                    ),
                  ),
                  const SizedBox(width: 16),
                   Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _selectedType = 'SERVICE'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _selectedType == 'SERVICE' ? Theme.of(context).primaryColor : Colors.transparent,
                         foregroundColor: _selectedType == 'SERVICE' ? Colors.white : Theme.of(context).primaryColor,
                      ),
                      child: const Text('Service'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // --- Updated Dropdown for Category ---
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: ['Painting', 'Music Gear', 'Live Performance', 'Crafts', 'Digital Art']
                    .map((label) => DropdownMenuItem(child: Text(label), value: label))
                    .toList(),
                onChanged: (value) {
                  setState(() { _selectedCategory = value!; });
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 32),

              // --- Final Submit Button ---
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitListing,
                      child: const Text('Create Listing'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}