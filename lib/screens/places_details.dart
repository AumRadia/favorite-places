import 'dart:io';
import 'package:favorite_places/providers/userplaces.dart';
import 'package:favorite_places/screens/map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:favorite_places/models/place.dart';

class placedetailscreen extends ConsumerWidget {
  const placedetailscreen({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        backgroundColor: Theme.of(context).colorScheme.surface,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        title: Text(
          place.title,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        centerTitle: true,
        actions: [
          // Delete icon added here
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              // Show a confirmation dialog before deleting
              final bool? confirmDelete = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(
                    'Confirm Deletion',
                    style: TextStyle(
                      color: Colors.white, // Title text color set to white
                    ),
                  ),
                  content: Text(
                    'Are you sure you want to delete this place?',
                    style: TextStyle(
                      color: Colors.white, // Content text color set to white
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(false); // User clicked No
                      },
                      child: Text(
                        'No',
                        style: TextStyle(
                          color:
                              Colors.white, // No button text color set to white
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(true); // User clicked Yes
                      },
                      child: Text(
                        'Yes',
                        style: TextStyle(
                          color: Colors
                              .white, // Yes button text color set to white
                        ),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmDelete == true) {
                // Proceed with deletion
                ref.read(userplacesprovider.notifier).deletePlace(place.id);
                Navigator.of(context).pop(); // Go back after deletion
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🖼️ Bigger Rectangle Image Card
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: 280, // 🔥 Taller image height
                  width: double.infinity,
                  child: Image.file(
                    File(place.image.path),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🏠 Address (Only this shown under image)
              Text(
                place.location.address,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 15,
                    ),
              ),
              const Spacer(),

              // 🗺️ View on Map Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => mapscreen(
                          location: place.location,
                          isselecting: false,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    shadowColor: Colors.black.withOpacity(0.2),
                  ),
                  icon: const Icon(Icons.map, size: 22, color: Colors.white),
                  label: Text(
                    'View on Map',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
