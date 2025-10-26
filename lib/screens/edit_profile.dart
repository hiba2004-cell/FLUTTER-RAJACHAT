import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:nurox_chat/components/text_form_builder.dart';
import 'package:nurox_chat/models/user.dart';
import 'package:nurox_chat/utils/firebase.dart';
import 'package:nurox_chat/utils/validation.dart';
import 'package:nurox_chat/view_models/profile/edit_profile_view_model.dart';
import 'package:nurox_chat/widgets/indicators.dart';

/// Écran de modification du profil utilisateur
/// Affiche un formulaire permettant de modifier username, pays, bio et photo
class EditProfile extends StatefulWidget {
  final UserModel? user;

  const EditProfile({this.user});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  UserModel? user;

  /// Retourne l'UID de l'utilisateur connecté
  /// Utilisé pour identifier l'utilisateur actuel dans Firebase
  String currentUid() {
    return firebaseAuth.currentUser!.uid;
  }

  /// Construit l'interface principale de l'écran
  /// 
  /// AFFICHAGE :
  /// - AppBar avec titre "Edit Profile" et bouton "SAVE"
  /// - Avatar circulaire cliquable (65px de rayon)
  /// - Formulaire avec 3 champs (Username, Country, Bio)
  /// - Overlay de chargement transparent pendant les opérations
  @override
  Widget build(BuildContext context) {
    EditProfileViewModel viewModel = Provider.of<EditProfileViewModel>(context);
    return LoadingOverlay(
      progressIndicator: circularProgress(context),
      isLoading: viewModel.loading,
      child: Scaffold(
        key: viewModel.scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          title: Text("Edit Profile"),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 25.0),
                child: GestureDetector(
                  // Sauvegarde les modifications du profil
                  onTap: () => viewModel.editProfile(context),
                  child: Text(
                    'SAVE',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15.0,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: ListView(
          children: [
            Center(
              child: GestureDetector(
                // Ouvre le sélecteur d'images
                onTap: () => viewModel.pickImage(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.transparent,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.3),
                        offset: new Offset(0.0, 0.0),
                        blurRadius: 2.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                  ),
                  /// AFFICHAGE DE L'AVATAR (3 cas possibles) :
                  /// 1. imgLink existe → Affiche image par défaut (AssetImage)
                  /// 2. image null → Affiche photo actuelle de l'utilisateur (AssetImage)
                  /// 3. image sélectionnée → Affiche nouvelle photo (FileImage)
                  child: viewModel.imgLink != null
                      ? Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: CircleAvatar(
                            radius: 65.0,
                            backgroundImage: AssetImage(viewModel.imgLink!),
                            backgroundColor: Colors.transparent,
                          ),
                        )
                      : viewModel.image == null
                          ? Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: CircleAvatar(
                                radius: 65.0,
                                backgroundImage:
                                    AssetImage(widget.user!.photoUrl!),
                                backgroundColor: Colors.transparent,
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: CircleAvatar(
                                radius: 65.0,
                                backgroundImage: FileImage(viewModel.image!),
                              ),
                            ),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            buildForm(viewModel, context)
          ],
        ),
      ),
    );
  }

  /// Construit le formulaire de modification du profil
  /// 
  /// AFFICHAGE :
  /// - Padding horizontal de 20px
  /// - 3 champs de saisie espacés de 10px :
  ///   1. Username avec icône personne
  ///   2. Country avec icône localisation
  ///   3. Bio (multiligne) avec label en gras
  /// 
  /// COMPORTEMENT :
  /// - Validation automatique lors de la saisie
  /// - Champs désactivés pendant le chargement (viewModel.loading)
  /// - Sauvegarde des valeurs via viewModel.setUsername/Country/Bio
  buildForm(EditProfileViewModel viewModel, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Form(
        key: viewModel.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            /// CHAMP USERNAME
            /// AFFICHAGE : TextFormBuilder avec icône person, validation temps réel
            /// VALIDATION : Via Validations.validateName
            /// ÉTAT : enabled = !viewModel.loading (désactivé pendant chargement)
            TextFormBuilder(
              enabled: !viewModel.loading,
              initialValue: widget.user!.username,
              prefix: Ionicons.person_outline,
              hintText: "Username",
              textInputAction: TextInputAction.next,
              validateFunction: Validations.validateName,
              onSaved: (String val) {
                viewModel.setUsername(val);
              },
            ),
            SizedBox(height: 10.0),
            /// CHAMP COUNTRY
            /// AFFICHAGE : TextFormBuilder avec icône pin, validation temps réel
            /// VALIDATION : Via Validations.validateName
            /// ÉTAT : enabled = !viewModel.loading (désactivé pendant chargement)
            TextFormBuilder(
              initialValue: widget.user!.country,
              enabled: !viewModel.loading,
              prefix: Ionicons.pin_outline,
              hintText: "Country",
              textInputAction: TextInputAction.next,
              validateFunction: Validations.validateName,
              onSaved: (String val) {
                viewModel.setCountry(val);
              },
            ),
            SizedBox(height: 10.0),
            /// LABEL BIO
            /// AFFICHAGE : Texte en gras au-dessus du champ bio
            Text(
              "Bio",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            /// CHAMP BIO
            /// AFFICHAGE : TextFormField multiligne (maxLines: null)
            /// VALIDATION : Maximum 1000 caractères, message "Bio must be short"
            /// MISE À JOUR : 
            /// - onSaved : Lors de la sauvegarde du formulaire
            /// - onChanged : En temps réel à chaque modification
            TextFormField(
              maxLines: null,
              initialValue: widget.user!.bio,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (String? value) {
                if (value!.length > 1000) {
                  return 'Bio must be short';
                }
                return null;
              },
              onSaved: (String? val) {
                viewModel.setBio(val!);
              },
              onChanged: (String val) {
                viewModel.setBio(val);
              },
            ),
          ],
        ),
      ),
    );
  }
}