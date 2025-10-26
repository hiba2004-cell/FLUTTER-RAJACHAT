import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nurox_chat/utils/firebase.dart';
//création de compte, connexion, déconnexion, réinitialisation de mot de passe..\.
class AuthService {
  User getCurrentUser() { //currentUser renvoie l'utilisateur connecté ou null s'il n'est pas connecté
    User user = firebaseAuth.currentUser!;
    return user;
  }

//Créer un utilisateur Firebase:inscription
  Future<bool> createUser(
      {String? name,
      User? user,
      String? email,
      String? country,
      String? password}) async {
    var res = await firebaseAuth.createUserWithEmailAndPassword(   //Firebase crée le compte avec email et mot de passe
      email: '$email',
      password: '$password',
    );
    if (res.user != null) {   //Si la création réussit donc user != null
      await saveUserToFirestore(name!, res.user!, email!, country!);  //Sauvegarde des informations supplémentaires dans Firestore
      return true;   // Succès
    } else {
      return false;   //Echec
    }
  }

//Enregistrer un utilisateur dans Firestore
  saveUserToFirestore(
      String name, User user, String email, String country) async {
    await usersRef.doc(user.uid).set({
      'username': name,   // Nom d'utilisateur
      'email': email,  // Email
      'time': Timestamp.now(),      // Date de création du compte
      'id': user.uid,    // ID unique Firebase
      'bio': "",       // Champ vide au départ
      'country': country,    // Pays de l'utilisateur
      'photoUrl': user.photoURL ?? '',   // URL photo (facultatif)
      'gender': '',                     // // Champ vide au départ
    });
  }

// Connexion d'un utilisateur Login a l'aide de son email et password 
  Future<bool> loginUser({String? email, String? password}) async {    // Firebase vérifie les identifiants
    var res = await firebaseAuth.signInWithEmailAndPassword(
      email: '$email',
      password: '$password',
    );

    if (res.user != null) {     // Si un utilisateur est bien renvoyé → connexion réussie
      return true;
    } else {
      return false;
    }
  }

  forgotPassword(String email) async {        // Mot de passe oublié
    await firebaseAuth.sendPasswordResetEmail(email: email);    // Firebase envoie un mail de réinitialisation
  }

  logOut() async {          //Déconnexion
    await firebaseAuth.signOut();
  }
 // Gestion des erreurs Firebase
  String handleFirebaseAuthError(String e) {        // Cette méthode traduit les messages d’erreur Firebase en texte clair
    if (e.contains("ERROR_WEAK_PASSWORD")) {
      return "Password is too weak";         // Mot de passe trop faible
    } else if (e.contains("invalid-email")) {
      return "Invalid Email";       // Email non valide
    } else if (e.contains("ERROR_EMAIL_ALREADY_IN_USE") ||
        e.contains('email-already-in-use')) {
      return "The email address is already in use by another account.";    // Email déjà pris
    } else if (e.contains("ERROR_NETWORK_REQUEST_FAILED")) {
      return "Network error occured!";   // Problème de connexion
    } else if (e.contains("ERROR_USER_NOT_FOUND") ||
        e.contains('firebase_auth/user-not-found')) {
      return "Invalid credentials.";          // Utilisateur non trouvé
    } else if (e.contains("ERROR_WRONG_PASSWORD") ||
        e.contains('wrong-password')) {
      return "Invalid credentials.";       // Mauvais mot de passe
    } else if (e.contains('firebase_auth/requires-recent-login')) {
      return 'This operation is sensitive and requires recent authentication.'
          ' Log in again before retrying this request.';
    } else {
      return e;
    }
  }
}
