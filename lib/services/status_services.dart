import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:nurox_chat/models/status.dart';
import 'package:nurox_chat/services/user_service.dart';
import 'package:nurox_chat/utils/firebase.dart';
import 'package:uuid/uuid.dart';

class StatusService {
  String statusId = const Uuid().v1();
  UserService userService = UserService();

  //pour snackBar afficher les erreurs
  void showSnackBar(String value, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  Future<String> sendStatus(StatusModel status) async {
    // Get all user IDs
    final snapshot = await usersRef.get();
    final ids = snapshot.docs.map((doc) => doc.get('uid') as String).toList();

    // Create a new status document
    final ref = statusRef.doc(); // create a doc with a generated ID

    // Save the full status data
    await ref.set({
      ...status.toJson(),
      'statusId': ref.id, // optional: store its own ID
      'whoCanSee': ids,
      'userId': firebaseAuth.currentUser!.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    // Return the new document ID
    return ref.id;
  }

  Future<String> uploadImage(File image) async {
    Reference storageReference =
        storage.ref().child("chats").child(uuid.v1()).child(uuid.v4());
    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.whenComplete(() => null);
    String imageUrl = await storageReference.getDownloadURL();
    return imageUrl;
  }
}
