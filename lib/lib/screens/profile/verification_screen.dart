import 'dart:io';
import 'package:atelier/main.dart';
import 'package:atelier/widgets/common/breathing_gradient_background.dart';
import 'package:atelier/widgets/common/glass_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  String _selectedDocType = 'ID Card';
  XFile? _frontImage;
  XFile? _backImage;
  bool _isLoading = false;

  Future<void> _pickImage(bool isFront) async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image != null) {
      setState(() {
        if (isFront) _frontImage = image;
        else _backImage = image;
      });
    }
  }

  Future<String> _uploadDocument(XFile image, String path) async {
    try {
      await supabase.storage.from('verification_documents').upload(path, File(image.path));
      // Note: We get the URL this way for non-public buckets
      final signedUrl = await supabase.storage.from('verification_documents').createSignedUrl(path, 60 * 60 * 24 * 365 * 10); // 10 year expiry
      return signedUrl;
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  Future<void> _submitVerification() async {
    if (!_formKey.currentState!.validate() || _frontImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields and upload the front of your document.'), backgroundColor: Colors.red));
      return;
    }
    setState(() { _isLoading = true; });

    try {
      final userId = supabase.auth.currentUser!.id;
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final frontPath = '$userId/front_$timestamp.jpg';
      final frontUrl = await _uploadDocument(_frontImage!, frontPath);

      String? backUrl;
      if (_backImage != null) {
        final backPath = '$userId/back_$timestamp.jpg';
        backUrl = await _uploadDocument(_backImage!, backPath);
      }

      await supabase.from('verifications').insert({
        'user_id': userId,
        'full_name': _fullNameController.text.trim(),
        'document_type': _selectedDocType,
        'document_front_url': frontUrl,
        'document_back_url': backUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification submitted! We will review it shortly.')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submission failed: $e'), backgroundColor: Colors.red));
      }
    }
    if (mounted) { setState(() { _isLoading = false; }); }
  }


  @override
  Widget build(BuildContext context) {
    return BreathingGradientBackground(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: const GlassAppBar(title: 'Get Verified'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 120, left: 16, right: 16, bottom: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Verification helps build trust in the community. Your information is kept private and secure.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[400])),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: 'Full Legal Name'),
                  validator: (value) => value!.isEmpty ? 'Please enter your full name' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedDocType,
                  items: ['ID Card', 'Passport', 'Driver\'s License']
                      .map((label) => DropdownMenuItem(child: Text(label), value: label))
                      .toList(),
                  onChanged: (value) { setState(() { _selectedDocType = value!; }); },
                  decoration: const InputDecoration(labelText: 'Document Type'),
                ),
                const SizedBox(height: 24),
                _buildImagePicker('Upload Front of Document', _frontImage, () => _pickImage(true)),
                const SizedBox(height: 16),
                _buildImagePicker('Upload Back of Document (Optional)', _backImage, () => _pickImage(false)),
                const SizedBox(height: 32),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submitVerification,
                        child: const Text('Submit for Verification'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(String label, XFile? image, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white30),
        ),
        child: image != null
            ? ClipRRect(borderRadius: BorderRadius.circular(11), child: Image.file(File(image.path), fit: BoxFit.cover))
            : Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.upload_file), const SizedBox(height: 8), Text(label)])),
      ),
    );
  }
}