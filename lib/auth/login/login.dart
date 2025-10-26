import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:nurox_chat/auth/register/register.dart';
import 'package:nurox_chat/components/password_text_field.dart';
import 'package:nurox_chat/components/text_form_builder.dart';
import 'package:nurox_chat/utils/validation.dart';
import 'package:nurox_chat/view_models/auth/login_view_model.dart';
import 'package:nurox_chat/widgets/indicators.dart';
import 'package:lottie/lottie.dart';

// Écran de connexion (Login Screen)

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();  // // Crée l'état associé à la page si l'utilisateur veut faire un login ou non 
}


class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    LoginViewModel viewModel = Provider.of<LoginViewModel>(context);  //Récupère le ViewModel via Provider

    return LoadingOverlay(
      progressIndicator: circularProgress(context),
      color: Theme.of(context).colorScheme.surface,  // prend la couleur d'arriere plan 
      isLoading: viewModel.loading,   // Affiche le loader si "loading" est vrai
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading:      
              true, //  Affiche automatiquement la flèche de retour
          elevation: 0,
          backgroundColor: Colors.transparent, 
          iconTheme: IconThemeData(color: Colors.black), 
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,  
        key: viewModel.scaffoldKey,
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height / 15),
            Container(
              height: 170.0,
              width: MediaQuery.of(context).size.width,
              child: Lottie.asset('assets/Global_Network.json'),
            ),
            SizedBox(height: 10.0),
            Center(
              child: Text(
                'Welcome back!',
                style: TextStyle(
                  fontSize: 23.0,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Center(
              child: Text(
                'Log into your account and get started!',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w300,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            SizedBox(height: 25.0),
            buildForm(context, viewModel),   // Appel du formulaire séparé pour plus de clarté
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Don\'t have an account?'),
                SizedBox(width: 5.0),
                GestureDetector(
                  onTap: () {  // Navigation vers la page Register
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => Register(),
                      ),
                    );
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  // construire le formulaire de connexion

  buildForm(BuildContext context, LoginViewModel viewModel) {
    return Form(
      key: viewModel.formKey,  // Clé pour la validation et la sauvegarde du formulaire
      autovalidateMode: AutovalidateMode.onUserInteraction,  // Validation automatique 
      child: Column(
        children: [
          TextFormBuilder(  // Champ e-mail
            enabled: !viewModel.loading,  // Désactivé pendant le chargement
            prefix: Ionicons.mail_outline,
            hintText: "Email",
            textInputAction: TextInputAction.next,
            validateFunction: Validations.validateEmail,  // Validation du format e-mail
            onSaved: (String val) {
              viewModel.setEmail(val);  // Sauvegarde la valeur dans le ViewModel
            },
            focusNode: viewModel.emailFN,
            nextFocusNode: viewModel.passFN, // Passe au champ mot de passe
          ),
          
          SizedBox(height: 15.0),
          PasswordFormBuilder(  // Champ mot de passe
            enabled: !viewModel.loading,
            prefix: Ionicons.lock_closed_outline,
            suffix: Ionicons.eye_outline,
            hintText: "Password",
            textInputAction: TextInputAction.done,
            validateFunction: Validations.validatePassword,
            submitAction: () => viewModel.login(context),   //Soumet le formulaire via la touche "Entrée"
            onSaved: (String val) {
              viewModel.setPassword(val);   // Sauvegarde le mot de passe dans le ViewModel
            },
            focusNode: viewModel.passFN,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: InkWell(
                onTap: () => viewModel.forgotPassword(context),   // Appelle la fonction de récupération de mot de passe 
                child: Container(
                  width: 130,
                  height: 40,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          Container(  // Bouton de connexion
            height: 45.0,
            width: 180.0,
            child: ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).colorScheme.secondary,
                ),
              ),
              // highlightElevation: 4.0,
              child: Text(
                'Log in'.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => viewModel.login(context),  // Appelle la fonction de connexion
            ),
          ),
        ],
      ),
    );
  }
}
