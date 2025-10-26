import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; 
import 'package:nurox_chat/models/user.dart';
import 'package:nurox_chat/screens/view_image.dart';
import 'package:nurox_chat/utils/firebase.dart';

class UserViewModel extends ChangeNotifier {
  // Objet utilisateur courant
  UserModel? _user;

  // Getter pour accéder à l'utilisateur depuis l'extérieur
  UserModel? get user => _user;

  // Instance FirebaseAuth pour obtenir l'utilisateur actuel
  FirebaseAuth auth = FirebaseAuth.instance;

  // Fonction pour définir l'utilisateur courant
  setUser() async {
    // Récupère le document utilisateur depuis Firestore
    DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();

    // Transforme les données du document en UserModel
    _user = UserModel.fromJson(doc.data() as Map<String, dynamic>);

    // Notifie tous les widgets abonnés que l'état a changé
    notifyListeners();
  }
}
