import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:favorite_places/widget/image_input.dart';
import 'package:favorite_places/widget/location_input.dart';
import 'package:favorite_places/providers/userplaces.dart';
import 'dart:io';

import '../models/place.dart';

class AddPlacescreen extends ConsumerStatefulWidget {
  const AddPlacescreen({super.key});

  @override
  ConsumerState<AddPlacescreen> createState() => _AddPlacescreenState();
}

class _AddPlacescreenState extends ConsumerState<AddPlacescreen> {
  final _titleController = TextEditingController();
  File? _selectedImage;
  placelocation? _selectedLocation;

  void _savePlace() {
    final enteredTitle = _titleController.text;

    if (enteredTitle.isEmpty ||
        _selectedImage == null ||
        _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    ref
        .read(userplacesprovider.notifier)
        .addplace(enteredTitle, _selectedImage!, _selectedLocation!);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Add New Place'),
        elevation: 2,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                filled: true,
                fillColor: theme.colorScheme.surface.withOpacity(0.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            //      const SizedBox(height: 10),
            ImageInput(
              onpickimage: (image) {
                _selectedImage = image;
              },
            ),
            //   const SizedBox(height: 20),
            LocationInput(
              onselectlocation: (location) {
                _selectedLocation = location;
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _savePlace,
              icon: const Icon(Icons.add_location_alt_rounded),
              label: const Text('Save Place'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
                shadowColor: theme.colorScheme.primary.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
