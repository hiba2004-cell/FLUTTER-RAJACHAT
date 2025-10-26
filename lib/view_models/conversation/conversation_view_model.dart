import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:nurox_chat/models/message.dart';
import 'package:nurox_chat/services/chat_service.dart';

class ConversationViewModel extends ChangeNotifier {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ChatService chatService = ChatService();
  bool uploadingImage = false;

  //  NEW: Use a local instance of ImagePicker for simplicity in this small class,
  // but use the correct methods.
  final ImagePicker _picker = ImagePicker();

  File? image;

  sendMessage(String chatId, Message message) {
    chatService.sendMessage(
      message,
      chatId,
    );
  }

  Future<String> sendFirstMessage(String recipient, Message message) async {
    String newChatId = await chatService.sendFirstMessage(
      message,
      recipient,
    );

    return newChatId;
  }

  setReadCount(String chatId, var user, int count) {
    chatService.setUserRead(chatId, user, count);
  }

  setUserTyping(String chatId, var user, bool typing) {
    chatService.setUserTyping(chatId, user, typing);
  }

  // Changed the return type to Future<String?>
  // and updated image picker usage.
  Future<String?> pickImage(
      {int? source, BuildContext? context, String? chatId}) async {
    // 1. Validate required arguments
    if (context == null || chatId == null) return null;

    // ✅ NEW: Use XFile? instead of PickedFile?
    XFile? pickedFile = source == 0
        ? await _picker.pickImage(
            // ✅ CORRECTED: Use pickImage for camera
            source: ImageSource.camera,
            imageQuality: 80, // Recommended
          )
        : await _picker.pickImage(
            // ✅ CORRECTED: Use pickImage for gallery
            source: ImageSource.gallery,
            imageQuality: 80, // Recommended
          );

    if (pickedFile != null) {
      // 2. Define the presets
      final List<CropAspectRatioPreset> presets = [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ];

      // Convert XFile to File for ImageCropper's sourcePath
      File imageFile = File(pickedFile.path);

      // 3. Perform Cropping
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path, // Use the path from the new File object

        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop image',
            // Ensure Theme.of(context!) is safe by checking for null context above
            toolbarColor: Theme.of(context).appBarTheme.backgroundColor,
            toolbarWidgetColor: Theme.of(context).iconTheme.color,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,

            // ✅ CORRECTED: aspectRatioPresets is inside AndroidUiSettings
            aspectRatioPresets: presets,
          ),
          IOSUiSettings(
            title: 'Crop image',
            minimumAspectRatio: 1.0,

            // ✅ CORRECTED: aspectRatioPresets is inside IOSUiSettings
            aspectRatioPresets: presets,
          ),
        ],
      );

      // 4. Safely handle navigation pop (assuming this was to close a bottom sheet/dialog)
      // This pop should usually happen *after* the image is picked but *before* the cropper,
      // but keeping it here for continuity.
      // It's safer to use Navigator.pop(context) if it's a dialog.
      // We will remove this, as the cropper likely opens a new screen and the pop should
      // be handled when the picker/dialog is closed.
      // If the code was inside a dialog, you would pop it before the cropper call.
      // Navigator.of(context).pop(); // ⚠️ Removed, reposition as needed

      if (croppedFile != null) {
        uploadingImage = true;
        image = File(croppedFile.path); // Store the cropped file
        notifyListeners();

        showInSnackBar("Uploading image...", context);

        // 5. Upload Image
        String imageUrl = await chatService.uploadImage(image!, chatId);

        // 6. Update state after successful upload
        uploadingImage = false;
        notifyListeners();

        return imageUrl;
      }
    }

    // Reset state if no image was selected or upload failed/cancelled
    uploadingImage = false;
    notifyListeners();
    return null; // Return null if selection was cancelled or cropping failed
  }

  void showInSnackBar(String value, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value),
      ),
    );
  }
}
