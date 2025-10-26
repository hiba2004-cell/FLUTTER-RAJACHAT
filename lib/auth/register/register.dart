// Importation des packages nécessaires
import 'package:flutter/cupertino.dart'; // Fournit des widgets au style iOS
import 'package:flutter/material.dart'; // Fournit les widgets de base de Flutter
import 'package:google_fonts/google_fonts.dart'; // Permet d'utiliser des polices Google Fonts
import 'package:ionicons/ionicons.dart'; // Fournit une collection d'icônes Ionicons
import 'package:loading_overlay/loading_overlay.dart'; // Permet d'afficher un indicateur de chargement en superposition
import 'package:nurox_chat/screens/mainscreen.dart'; // Importe la page principale après inscription
import 'package:provider/provider.dart'; // Gère l’état avec le package Provider
import 'package:nurox_chat/components/password_text_field.dart'; // Champ personnalisé pour le mot de passe
import 'package:nurox_chat/components/text_form_builder.dart'; // Champ personnalisé pour le texte
import 'package:nurox_chat/utils/validation.dart'; // Contient les fonctions de validation
import 'package:nurox_chat/view_models/auth/register_view_model.dart'; // ViewModel pour la logique d’inscription
import 'package:nurox_chat/widgets/indicators.dart'; // Widgets d’indicateurs visuels (chargement, etc.)

// Classe principale représentant la page d'inscription
class Register extends StatefulWidget {
  @override
  _RegisterState createState() =>
      _RegisterState(); // Crée un état associé à ce widget
}

// Classe d’état pour la page Register
class _RegisterState extends State<Register> {
  @override
  Widget build(BuildContext context) {
    // Récupération du ViewModel d’inscription via Provider
    RegisterViewModel viewModel = Provider.of<RegisterViewModel>(context);

    return LoadingOverlay(
      // Widget pour afficher un indicateur de chargement au-dessus du contenu
      progressIndicator:
          circularProgress(context), // Indicateur circulaire personnalisé
      isLoading:
          viewModel.loading, // Affiche l’overlay quand "loading" est vrai
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading:
              true, // Affiche automatiquement la flèche de retour
          elevation: 0, // Supprime l’ombre sous l’AppBar
          backgroundColor: Colors.transparent, // AppBar transparente
          iconTheme: IconThemeData(
              color: Colors.black), // Couleur de l’icône de retour
        ),
        key: viewModel
            .scaffoldKey, // Clé globale du Scaffold (utile pour les SnackBars, etc.)
        body: ListView(
          // Liste déroulante contenant tout le contenu de la page
          padding: EdgeInsets.symmetric(
              horizontal: 20.0, vertical: 40.0), // Espacement intérieur
          children: [
            SizedBox(
                height: MediaQuery.of(context).size.height /
                    27), // Espacement vertical proportionnel à la taille de l’écran
            Text(
              // Texte d’introduction de la page
              'Welcome to Raja Chat\nCreate a new account and connect with friends',
              style: GoogleFonts.nunitoSans(
                // Police Google Nunito Sans
                fontWeight: FontWeight.bold,
                fontSize: 25.0,
              ),
            ),
            SizedBox(height: 30.0), // Espace après le texte
            buildForm(viewModel,
                context), // Appel de la méthode pour construire le formulaire
            SizedBox(height: 30.0), // Espace après le formulaire
            Row(
              // Ligne contenant le texte "Already have an account ?"
              mainAxisAlignment:
                  MainAxisAlignment.center, // Centrage horizontal
              children: [
                Text('Already have an account ? '), // Texte statique
                GestureDetector(
                  // Rends le texte "Login" cliquable
                  onTap: () => Navigator.pop(
                      context), // Revient à la page précédente (login)
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context)
                          .colorScheme
                          .secondary, // Couleur secondaire du thème
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

  // Méthode pour construire le formulaire d'inscription
  buildForm(RegisterViewModel viewModel, BuildContext context) {
    return Form(
      key: viewModel.formKey, // Clé unique pour identifier le formulaire
      autovalidateMode: AutovalidateMode
          .onUserInteraction, // Valide automatiquement à la saisie
      child: Column(
        // Les champs du formulaire sont empilés verticalement
        children: [
          TextFormBuilder(
            // Champ personnalisé pour le nom d'utilisateur
            enabled: !viewModel.loading, // Désactivé pendant le chargement
            prefix: Ionicons.person_outline, // Icône utilisateur
            hintText: "Username", // Texte d’indication
            textInputAction:
                TextInputAction.next, // Passe au champ suivant après "Entrée"
            validateFunction:
                Validations.validateName, // Fonction de validation du nom
            onSaved: (String val) {
              viewModel.setName(val); // Enregistre le nom dans le ViewModel
            },
            focusNode: viewModel.usernameFN, // Gère le focus de ce champ
            nextFocusNode: viewModel.emailFN, // Définit le champ suivant
          ),
          SizedBox(height: 20.0), // Espacement entre les champs
          TextFormBuilder(
            // Champ personnalisé pour l’e-mail
            enabled: !viewModel.loading,
            prefix: Ionicons.mail_outline, // Icône d’enveloppe
            hintText: "Email", // Indication pour l’utilisateur
            textInputAction: TextInputAction.next,
            validateFunction:
                Validations.validateEmail, // Vérifie la validité de l’e-mail
            onSaved: (String val) {
              viewModel.setEmail(val); // Sauvegarde de l’e-mail
            },
            focusNode: viewModel.emailFN, // Focus actuel
            nextFocusNode: viewModel.countryFN, // Champ suivant
          ),
          SizedBox(height: 20.0),
          TextFormBuilder(
            // Champ personnalisé pour le pays
            enabled: !viewModel.loading,
            prefix: Ionicons.pin_outline, // Icône d’épingle de localisation
            hintText: "Country",
            textInputAction: TextInputAction.next,
            validateFunction:
                Validations.validateName, // Validation du texte saisi
            onSaved: (String val) {
              viewModel.setCountry(val); // Sauvegarde du pays dans le ViewModel
            },
            focusNode: viewModel.countryFN,
            nextFocusNode: viewModel.passFN, // Champ suivant : mot de passe
          ),
          SizedBox(height: 20.0),
          PasswordFormBuilder(
            // Champ personnalisé pour le mot de passe
            enabled: !viewModel.loading,
            prefix: Ionicons.lock_closed_outline, // Icône de cadenas fermé
            suffix: Ionicons
                .eye_outline, // Icône d’œil pour afficher/masquer le mot de passe
            hintText: "Password",
            textInputAction: TextInputAction.next,
            validateFunction: Validations
                .validatePassword, // Vérifie la solidité du mot de passe
            obscureText: true, // Masque le texte saisi
            onSaved: (String val) {
              viewModel.setPassword(val); // Sauvegarde du mot de passe
            },
            focusNode: viewModel.passFN,
            nextFocusNode: viewModel
                .cPassFN, // Champ suivant : confirmation du mot de passe
          ),
          SizedBox(height: 20.0),
          PasswordFormBuilder(
            // Champ personnalisé pour la confirmation du mot de passe
            enabled: !viewModel.loading,
            prefix: Ionicons.lock_open_outline, // Icône de cadenas ouvert
            hintText: "Confirm Password",
            textInputAction:
                TextInputAction.done, // Indique la fin du formulaire
            validateFunction: Validations
                .validatePassword, // Valide le mot de passe de confirmation
            submitAction: () => viewModel.register(
                context), // Appelle la méthode d’inscription à la soumission
            obscureText: true, // Cache le texte
            onSaved: (String val) {
              viewModel.setConfirmPass(
                  val); // Sauvegarde du mot de passe de confirmation
            },
            focusNode: viewModel.cPassFN,
          ),
          SizedBox(height: 25.0),
          Container(
            // Conteneur pour le bouton "Sign Up"
            height: 45.0, // Hauteur du bouton
            width: 180.0, // Largeur du bouton
            child: ElevatedButton(
              // Bouton d’action principal
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  // Forme arrondie
                  RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(40.0), // Rayon de bordure
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context)
                        .colorScheme
                        .secondary), // Couleur du bouton
              ),
              child: Text(
                'sign up'.toUpperCase(), // Texte du bouton en majuscules
                style: TextStyle(
                  color: Colors.white, // Couleur du texte
                  fontSize: 12.0, // Taille du texte
                  fontWeight: FontWeight.w600, // Poids moyen du texte
                ),
              ),
              onPressed: () => viewModel
                  .register(context), // Appelle la fonction register() au clic
            ),
          ),
        ],
      ),
    );
  }
}
