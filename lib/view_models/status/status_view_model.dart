import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:nurox_chat/models/status.dart';
import 'package:nurox_chat/posts/story/confrim_status.dart';
import 'package:nurox_chat/services/ImagePickerService.dart';
import 'package:nurox_chat/services/status_services.dart';
import 'package:nurox_chat/services/user_service.dart';
import 'package:nurox_chat/utils/constants.dart';

class StatusViewModel extends ChangeNotifier {
  // Services
  UserService userService = UserService();
  StatusService statusService = StatusService();
  final ImagePickerService _imagePickerService = ImagePickerService();

  // Keys
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Variables
  bool loading = false;
  String? username;
  File? mediaUrl; // Holds the local image file
  String? description;
  String? email;
  String? userDp;
  String? userId;
  String? imgLink;
  bool edit = false;
  String? id;

  // integers
  int pageIndex = 0;

  setDescription(String val) {
    print('SetDescription $val');
    description = val;
    notifyListeners();
  }

  // Functions
  Future<void> pickImage({bool camera = false, BuildContext? context}) async {
    // Changed return type to void
    loading = true;
    notifyListeners();

    if (context == null) return; // Null safety check for context

    try {
      File? pickedFile;

      // ✅ DELEGATE IMAGE PICKING TO THE SERVICE
      if (camera) {
        pickedFile = await _imagePickerService.pickImageFromCamera();
      } else {
        pickedFile = await _imagePickerService.pickImageFromGallery();
      }

      // 1. CHECK IF SELECTION WAS CANCELLED
      if (pickedFile == null) {
        loading = false;
        notifyListeners();
        showInSnackBar('Selection Cancelled', context);
        return;
      }

      // 2. Define the presets once for cleaner code
      final List<CropAspectRatioPreset> presets = [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ];

      // 3. Perform Cropping
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path, // Use the path from the File object
        compressQuality: 80, // Recommended for efficiency

        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor:
                Constants.lightAccent, // Assuming Constants is defined
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: presets, // Correct placement
          ),
          IOSUiSettings(
            title: 'Crop Image',
            minimumAspectRatio: 1.0,
            aspectRatioPresets: presets, // Correct placement
          ),
        ],
      );

      // 4. Update State and Navigate
      if (croppedFile != null) {
        mediaUrl = File(croppedFile.path); // Store the final cropped file

        loading = false;
        notifyListeners(); // Notify UI to update loading state and show image

        // Navigate to ConfirmStatus screen
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => ConfirmStatus(),
          ),
        );
      } else {
        // Cropping cancelled
        loading = false;
        notifyListeners();
        showInSnackBar('Cropping Cancelled', context);
      }
    } catch (e) {
      // 5. Catch and Handle Errors
      print('Image Picking/Cropping Error: $e');
      loading = false;
      notifyListeners();
      showInSnackBar('An error occurred. Check permissions.', context);
    }
  }

  // send message
  sendStatus(StatusModel message) {
    return statusService.sendStatus(
      message,
    );
  }

  resetPost() {
    mediaUrl = null;
    description = null;
    edit = false;
    notifyListeners();
  }

  void showInSnackBar(String value, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}
