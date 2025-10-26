import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:nurox_chat/utils/file_utils.dart';
import 'package:nurox_chat/utils/firebase.dart';

abstract class Service {
  // fonction pour téléverser des images dans Firebase Storage et récupérer l’URL.
  Future<String> uploadImage(Reference ref, File file) async {
    String ext = FileUtils.getFileExtension(file);
    Reference storageReference = ref.child("${uuid.v4()}.$ext");
    UploadTask uploadTask = storageReference.putFile(file);
    await uploadTask.whenComplete(() => null);
    String fileUrl = await storageReference.getDownloadURL();
    return fileUrl;
  }
}
