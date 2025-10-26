import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nurox_chat/models/post.dart';
import 'package:nurox_chat/screens/mainscreen.dart';
import 'package:nurox_chat/services/ImagePickerService.dart';
import 'package:nurox_chat/services/post_service.dart';
import 'package:nurox_chat/services/user_service.dart';
import 'package:nurox_chat/utils/firebase.dart';

class PostsViewModel extends ChangeNotifier {
  //Services
  UserService userService = UserService();
  PostService postService = PostService();

  //Keys
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  //Variables
  bool loading = false;
  String? username;
  // File? mediaUrl;
  final picker = ImagePicker();
  String? location;
  Position? position;
  Placemark? placemark;
  String? bio;
  String? description;
  String? email;
  String? commentData;
  String? ownerId;
  String? userId;
  String? type;
  File? userDp;
  String? imgLink;
  bool edit = false;
  String? id;

  //controllers
  TextEditingController locationTEC = TextEditingController();

  final ImagePickerService _imagePickerService = ImagePickerService();

  File? _mediaUrl; // This will store the File for local display
  File? get mediaUrl => _mediaUrl;

  // 2. Methods to fetch and save the image
  Future<void> fetchImageFromGallery() async {
    // Call the service class method
    final File? imageFile = await _imagePickerService.pickImageFromGallery();

    if (imageFile != null) {
      _mediaUrl = imageFile;
      imgLink = null; // Clear remote link when a new local file is picked
      notifyListeners(); // Notify UI to rebuild and show the new image
    }
  }

  Future<void> fetchImageFromCamera() async {
    final File? imageFile = await _imagePickerService.pickImageFromCamera();

    if (imageFile != null) {
      _mediaUrl = imageFile;
      imgLink = null;
      notifyListeners();
    }
  }

  //Setters
  setEdit(bool val) {
    edit = val;
    notifyListeners();
  }

  setPost(PostModel post) {
    description = post.description;
    imgLink = post.mediaUrl;
    location = post.location;
    edit = true;
    edit = false;
    notifyListeners();
  }

  setUsername(String val) {
    print('SetName $val');
    username = val;
    notifyListeners();
  }

  setDescription(String val) {
    print('SetDescription $val');
    description = val;
    notifyListeners();
  }

  setLocation(String val) {
    print('SetCountry $val');
    location = val;
    notifyListeners();
  }

  setBio(String val) {
    print('SetBio $val');
    bio = val;
    notifyListeners();
  }

  final LocationSettings settings = LocationSettings(
    accuracy: LocationAccuracy.high,
    // Add platform-specific settings here if needed (AndroidSettings, AppleSettings, etc.)
  );

  //Functions
  Future<void> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if location services are enabled on the device
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, handle this case (e.g., show a dialog)
      print('Location services are disabled.');
      return;
    }

    // 2. Check current permission status
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // 3. Request permission if denied
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // User denied permission again
        print('Location permissions are denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, direct the user to app settings
      print(
          'Location permissions are permanently denied, we cannot request permissions.');
      return;
    }

    // If the code reaches here, permission is granted (whileInUse or always)
    print('Location usage is enabled.');

    try {
      // You can now safely call Geolocator.getCurrentPosition()
      position = await Geolocator.getCurrentPosition(
        // Use the required settings parameter
        locationSettings: settings,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
          position!.latitude, position!.longitude);

      placemark = placemarks[0];
      location = " ${placemarks[0].locality}, ${placemarks[0].country}";
      locationTEC.text = location!;
      print('Location fetched: $location');
      setLocation(location ?? this.location ?? '');
    } catch (e) {
      // If it fails, the error will be caught here instead of crashing
      print('Error during getCurrentPosition or geocoding: $e');
      // Handle the error (e.g., show a default location)
      return;
    }
  }

  uploadPosts(BuildContext context) async {
    try {
      loading = true;
      notifyListeners();
      await postService.uploadPost(location!, description!, mediaUrl);
      print("Post Uploaded");
      loading = false;
      resetPost();
      notifyListeners();
    } catch (e) {
      print("my error " + e.toString());
      loading = false;
      resetPost();
      showInSnackBar('An error has shown', context);
      notifyListeners();
    }
  }

  uploadProfilePicture(BuildContext context) async {
    if (mediaUrl == null) {
      showInSnackBar('Please select an image', context);
    } else {
      try {
        loading = true;
        notifyListeners();
        await postService.uploadProfilePicture(
            mediaUrl!, firebaseAuth.currentUser!);
        loading = false;
        Navigator.of(context)
            .pushReplacement(CupertinoPageRoute(builder: (_) => TabScreen()));
        notifyListeners();
      } catch (e) {
        print(e);
        loading = false;
        showInSnackBar('Uploaded successfully!', context);
        notifyListeners();
      }
    }
  }

  resetPost() {
    _mediaUrl = null;
    description = null;
    location = null;
    edit = false;
    notifyListeners();
  }

  void showInSnackBar(String value, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}
