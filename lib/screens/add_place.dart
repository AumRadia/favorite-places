import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/providers/userplaces.dart';
import 'package:favorite_places/widget/image_input.dart';
import 'package:favorite_places/widget/location_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

class AddPlacescreen extends ConsumerStatefulWidget {
  const AddPlacescreen({super.key});

  @override
  ConsumerState<AddPlacescreen> createState() => _AddPlacescreenState();
}

class _AddPlacescreenState extends ConsumerState<AddPlacescreen> {
  final _titlecontroller = TextEditingController();
  File? _selectedimage;
  placelocation? _selectedlocation;

  void _saveplace() {
    final enterredtitle = _titlecontroller.text;

    //print('Title: $enteredTitle');
    print('Selected Image: $_selectedimage');
    print('Selected Location: $_selectedlocation');

    if (enterredtitle.isEmpty ||
        _selectedimage == null ||
        _selectedlocation == null) {
      print('Error: Image or location is null');
      return;
    }

    ref
        .read(userplacesprovider.notifier)
        .addplace(enterredtitle, _selectedimage!, _selectedlocation!);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new place'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Title'),
              controller: _titlecontroller,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            ImageInput(
              onpickimage: (image) {
                _selectedimage = image;
              },
            ),
            const SizedBox(
              height: 16,
            ),
            LocationInput(
              onselectlocation: (location) {
                _selectedlocation = location;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
                onPressed: _saveplace,
                icon: const Icon(Icons.add),
                label: const Text('add place'))
          ],
        ),
      ),
    );
  }
}
