import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class ImageInput extends StatefulWidget {
  const ImageInput({super.key, required this.onpickimage});

  final void Function(File image) onpickimage;

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _selectedImage;

  Future<void> _takePicture() async {
    final cameraStatus = await Permission.camera.request();
    if (!cameraStatus.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission is required')),
      );
      return;
    }

    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );

    if (pickedImage == null) return;

    setState(() {
      _selectedImage = File(pickedImage.path);
    });
    widget.onpickimage(_selectedImage!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _takePicture,
      child: Container(
        width: double.infinity,
        height: 210,
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            width: 2,
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_rounded,
                      size: 50,
                      color: theme.colorScheme.primary.withOpacity(0.8),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tap to take a picture',
                      style: theme.textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
