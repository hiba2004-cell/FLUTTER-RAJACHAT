import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nurox_chat/services/user_service.dart';
import 'package:nurox_chat/models/user.dart';
import 'package:nurox_chat/utils/constants.dart';

class EditProfileViewModel extends ChangeNotifier {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool validate = false;
  bool loading = false;
  UserService userService = UserService();

  // ✅ Kept the picker instance, but we'll use the correct method
  final ImagePicker picker = ImagePicker();

  UserModel? user;
  String? country;
  String? username;
  String? bio;
  File? image; // Holds the local image file for upload
  String? imgLink; // Holds the remote image URL

  setUser(UserModel val) {
    user = val;
    notifyListeners();
  }

  setImage(UserModel user) {
    imgLink = user.photoUrl;
  }

  setCountry(String val) {
    print('SetCountry $val');
    country = val;
    notifyListeners();
  }

  setBio(String val) {
    print('SetBio$val');
    bio = val;
    notifyListeners();
  }

  setUsername(String val) {
    print('SetUsername$val');
    username = val;
    notifyListeners();
  }

  editProfile(BuildContext context) async {
    FormState form = formKey.currentState!;
    form.save();
    if (!form.validate()) {
      validate = true;
      notifyListeners();
      showInSnackBar(
          'Please fix the errors in red before submitting.', context);
    } else {
      try {
        loading = true;
        notifyListeners();
        bool success = await userService.updateProfile(
          //  user: user, // Commented out as per original code
          image: image,
          username: username,
          bio: bio,
          country: country,
        );
        print(success);
        if (success) {
          clear();
          Navigator.pop(context);
        }
      } catch (e) {
        loading = false;
        notifyListeners();
        print(e);
      }
      loading = false;
      notifyListeners();
    }
  }

  Future<void> pickImage({bool camera = false, BuildContext? context}) async {
    loading = true;
    notifyListeners();

    if (context == null) return; // Null safety check

    try {
      // ✅ CORRECTED: Use XFile? and picker.pickImage()
      XFile? pickedFile = await picker.pickImage(
        source: camera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80, // Recommended: helps reduce file size
      );

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
        // Use the path from the XFile object
        sourcePath: pickedFile.path,

        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor:
                Constants.lightAccent, // Assuming Constants is defined
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            // ✅ CORRECTED: aspectRatioPresets is now inside AndroidUiSettings
            aspectRatioPresets: presets,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            minimumAspectRatio: 1.0,
            // ✅ CORRECTED: aspectRatioPresets is now inside IOSUiSettings
            aspectRatioPresets: presets,
          ),
        ],
      );

      // 4. Update State
      if (croppedFile != null) {
        image = File(croppedFile.path); // Store the final cropped file
      } else {
        showInSnackBar('Cropping Cancelled', context);
      }

      loading = false;
      notifyListeners();
    } catch (e) {
      // 5. Catch Errors
      loading = false;
      notifyListeners();
      print('Image Picking/Cropping Error: $e');
      showInSnackBar('An error occurred. Check permissions.', context);
    }
  }

  clear() {
    image = null;
    notifyListeners();
  }

  void showInSnackBar(String value, BuildContext context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}
