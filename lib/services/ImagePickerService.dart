import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Prompts the user to select an image from the gallery.
  /// Returns a File object on success, or null if cancelled or failed.
  Future<File?> pickImageFromGallery() async {
    try {
      // Use the modern pickImage method which returns XFile
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Optional: Adjust quality to reduce file size
      );

      if (pickedFile != null) {
        // Convert the XFile to a standard dart:io File
        return File(pickedFile.path);
      }
      return null; // User cancelled
    } catch (e) {
      print('Error selecting image from gallery: $e');
      // Handle permission errors or other exceptions here
      return null;
    }
  }

  /// Prompts the user to take a new photo with the camera.
  /// Returns a File object on success, or null if cancelled or failed.
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null; // User cancelled
    } catch (e) {
      print('Error taking photo with camera: $e');
      return null;
    }
  }
}
