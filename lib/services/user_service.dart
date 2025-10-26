import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nurox_chat/models/user.dart';
import 'package:nurox_chat/services/services.dart';
import 'package:nurox_chat/utils/firebase.dart';

class UserService extends Service {
  //get the authenticated uis
  String currentUid() {
    return firebaseAuth.currentUser!.uid;
  }

//updates user profile in the Edit Profile Screen
  updateProfile(
      {File? image, String? username, String? bio, String? country}) async {
    DocumentSnapshot doc = await usersRef.doc(currentUid()).get();
    var users = UserModel.fromJson(doc.data() as Map<String, dynamic>);
    users.username = username;
    users.bio = bio;
    users.country = country;
    if (image != null) {
      users.photoUrl = await uploadImage(profilePic, image);
    }
    await usersRef.doc(currentUid()).update({
      'username': username,
      'bio': bio,
      'country': country,
      ...(users.photoUrl != null ? {'photoUrl': users.photoUrl} : {}),
    });

    return true;
  }
}
