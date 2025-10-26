import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import for Firebase Storage
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:nurox_chat/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:nurox_chat/models/enum/message_type.dart';
import 'package:nurox_chat/models/status.dart';
import 'package:nurox_chat/utils/firebase.dart'; // Contains statusRef, firebaseAuth, uuid, storage/firebaseStorage
import 'package:nurox_chat/view_models/status/status_view_model.dart';
import 'package:nurox_chat/widgets/indicators.dart';

class ConfirmStatus extends StatefulWidget {
  @override
  State<ConfirmStatus> createState() => _ConfirmStatusState();
}

class _ConfirmStatusState extends State<ConfirmStatus> {
  // Use StatefulWidget's loading state only for the overlay
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    StatusViewModel viewModel = Provider.of<StatusViewModel>(context);
    return Scaffold(
      body: LoadingOverlay(
        isLoading: loading,
        progressIndicator: circularProgress(context),
        child: Center(
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: Image.file(viewModel.mediaUrl!),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 10.0,
        child: Container(
          constraints: BoxConstraints(maxHeight: 100.0),
          child: Row(
            children: [
              Flexible(
                child: TextFormField(
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Theme.of(context).textTheme.titleLarge!.color,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10.0),
                    enabledBorder: InputBorder.none,
                    border: InputBorder.none,
                    hintText: "Type your caption",
                    hintStyle: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge!.color,
                    ),
                  ),
                  onSaved: (val) {
                    if (val != null) viewModel.setDescription(val);
                  },
                  onChanged: (val) {
                    viewModel.setDescription(val);
                  },
                  maxLines: null,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
        onPressed: () async {
          setState(() {
            loading = true;
          });

          try {
            // Get the image URL (in real app but for me , i haven't activated storage so i can't use it)
            // String url = await uploadMedia(viewModel.mediaUrl!);
            String url = Constants.defaultImage;

            StatusModel message = StatusModel(
              url: url,
              caption: viewModel.description,
              type: MessageType.IMAGE,
              viewers: [],
            );

            String refId = await viewModel.sendStatus(message);

            print('Status uploaded with ID: $refId');

            // Success: Turn off loading and navigate back
            setState(() {
              loading = false;
            });

            Navigator.pop(context);
            Navigator.pop(context);
          } catch (e) {
            // Failure: Turn off loading and show error
            print('Error during status upload: $e');
            setState(() {
              loading = false;
            });
          }
        },
      ),
    );
  }

// Inside _ConfirmStatusState in confirm_status.dart

  Future<String> uploadMedia(File image) async {
    // 1. Create a unique, clear path for the image
    String fileName = '${uuid.v1()}_${uuid.v4()}'; // Create a unique filename

    // 2. Define the storage reference
    // Use the storage instance to get the root reference, then define the path.
    Reference storageReference =
        statuses.child(fileName); // Reference the file directly

    // 3. Create and await the UploadTask
    try {
      UploadTask uploadTask = storageReference.putFile(image);

      // Await the task completion and get the snapshot
      // TaskSnapshot provides the reliable result of the upload.
      TaskSnapshot snapshot = await uploadTask;

      // 4. Get the download URL
      String imageUrl = await snapshot.ref.getDownloadURL();
      return imageUrl;
    } on FirebaseException catch (e) {
      // Log the specific Firebase Storage error
      print('Firebase Storage Error during upload: ${e.code} - ${e.message}');

      // Re-throw or handle as needed, but this prevents the function from returning
      // a successful URL path when the upload actually failed.
      throw Exception('Failed to upload media: ${e.message}');
    }
  }
}
