import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PhotoPickerModal extends StatefulWidget {
  final Function(File) onImageSelected;

  const PhotoPickerModal({
    super.key,
    required this.onImageSelected,
  });

  @override
  State<PhotoPickerModal> createState() => _PhotoPickerModalState();
}

class _PhotoPickerModalState extends State<PhotoPickerModal> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];

  @override
  void initState() {
    super.initState();
    _loadRecentImages();
  }

  Future<void> _loadRecentImages() async {
    try {
      // Simulate loading recent images from gallery
      // In a real app, you would use a package like photo_manager
      // For now, we'll create a simple interface
      setState(() {
        // This is a placeholder - in a real app you'd load actual gallery images
      });
    } catch (e) {
      print('Error loading images: $e');
    }
  }

  Future<void> _openCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (image != null) {
        widget.onImageSelected(File(image.path));
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error opening camera: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        widget.onImageSelected(File(image.path));
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error picking from gallery: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '写真を選択',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Photo grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: 10, // First item is camera, rest are placeholder gallery items
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Camera button
                    return GestureDetector(
                      onTap: _openCamera,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFE0E0E0),
                            width: 1,
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 32,
                              color: Color(0xFF666666),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'カメラ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    // Gallery placeholder items
                    return GestureDetector(
                      onTap: _pickFromGallery,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFE0E0E0),
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            size: 32,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          
          // Bottom options
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickFromGallery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('ライブラリから選択'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}