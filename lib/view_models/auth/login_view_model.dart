import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nurox_chat/screens/mainscreen.dart';
import 'package:nurox_chat/services/auth_service.dart';
import 'package:nurox_chat/utils/validation.dart';

class LoginViewModel extends ChangeNotifier {
  // Ce ViewModel gère la logique du formulaire de connexion (login)
  final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>(); //  Clé globale pour le Scaffold
  final GlobalKey<FormState> formKey = GlobalKey<
      FormState>(); // Clé globale pour le formulaire afin d'accéder à son état
  bool validate =
      false; //  Permet de déclencher la validation automatique après une première erreur
  bool loading = false; // Indique si le chargement est en cours
  String? email, password;
  // FocusNodes permettent de contrôler le focus entre les champs
  FocusNode emailFN = FocusNode();
  FocusNode passFN = FocusNode();
  AuthService auth = AuthService(); //Service d'authentification

  login(BuildContext context) async {
    //Méthode principale de connexion
    FormState form = formKey.currentState!;
    form.save();
    if (!form.validate()) {
      //Si le formulaire est invalide affiche une erreur
      validate = true;
      notifyListeners(); // Notifie l’UI pour mettre à jour l’état
      showInSnackBar(
          'Please fix the errors in red before submitting.', context);
    } else {
      // Sinon le formulaire est valide il commence la tentative de connexion
      loading = true;
      notifyListeners();
      try {
        bool success = await auth.loginUser(
          // Appel du service d'authentification
          email: email,
          password: password,
        );
        print(success);
        notifyListeners();
        if (success) {
          //Si la connexion réussit il redirige vers la page principale
          Navigator.of(context)
              .pushReplacement(CupertinoPageRoute(builder: (_) => TabScreen()));
        }
      } catch (e) {
        // Si une erreur se produit affiche l'erreur dans une SnackBar
        loading = false;
        notifyListeners();
        print(e);
        showInSnackBar(
            '${auth.handleFirebaseAuthError(e.toString())}', context);
      }
      loading = false;
      notifyListeners();
    }
  }

  forgotPassword(BuildContext context) async {
    //Fonction "Mot de passe oublié"
    loading = true;
    notifyListeners();
    FormState form = formKey.currentState!;
    form.save();
    print(Validations.validateEmail(email));
    if (Validations.validateEmail(email) != null) {
      //Vérifie si l'email est valide avant d’envoyer un mail de réinitialisation
      showInSnackBar(
          'Please input a valid email to reset your password.', context);
    } else {
      try {
        await auth.forgotPassword(
            email!); //Appel du service pour réinitialiser le mot de passe
        showInSnackBar(
            'Please check your email for instructions '
            'to reset your password',
            context);
      } catch (e) {
        showInSnackBar('${e.toString()}', context); //Gestion d’erreur simple
      }
    }
    loading = false; // Fin du chargement
    notifyListeners();
  }

  setEmail(val) {
    // Mise à jour de l'email
    email = val; // Assigne la nouvelle valeur
    notifyListeners(); // Met à jour les widgets dépendants
  }

  setPassword(val) {
    //Mise à jour du mot de passe
    password = val;
    notifyListeners();
  }

  void showInSnackBar(String value, context) {
    //Fonction utilitaire pour afficher un message (SnackBar)
    ScaffoldMessenger.of(context)
        .removeCurrentSnackBar(); // Supprime les anciens SnackBars avant d’en afficher un nouveau
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(value))); // Affiche un nouveau message
  }
}
