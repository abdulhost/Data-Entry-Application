// lib/features/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State createState() => _ProfileState();
}

class _ProfileState extends State<ProfileScreen> {
  File? image;

  Future pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => image = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: pickImage,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: image != null ? FileImage(image!) : null,
              child: image == null ? const Icon(Icons.person, size: 40) : null,
            ),
          ),
          const SizedBox(height: 20),
          const Text("Tap to upload logo"),
        ],
      ),
    );
  }
}