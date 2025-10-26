import 'package:flutter/material.dart'; // Importe Flutter pour construire l'interface utilisateur
import 'package:nurox_chat/components/custom_card.dart'; // Importe le composant CustomCard
import 'package:nurox_chat/utils/constants.dart'; // Importe les constantes de l'application

// Widget pour construire un champ de formulaire texte personnalisé
class TextFormBuilder extends StatefulWidget {
  final String? initialValue; // Valeur initiale du champ
  final bool? enabled; // Détermine si le champ est activé ou non
  final String? hintText; // Texte d'indice
  final TextInputType? textInputType; // Type de clavier
  final TextEditingController? controller; // Contrôleur pour manipuler le texte
  final TextInputAction? textInputAction; // Action du clavier (ex: next, done)
  final bool obscureText; // Masquer le texte (ex: mot de passe)
  final FocusNode? focusNode,
      nextFocusNode; // Focus pour navigation entre champs
  final VoidCallback? submitAction; // Action à la soumission du champ
  final FormFieldValidator<String>? validateFunction; // Fonction de validation
  final void Function(String)? onSaved,
      onChange; // Callback lors de la sauvegarde ou du changement
  final Key? key; // Clé du widget
  final IconData? prefix; // Icône de préfixe
  final IconData? suffix; // Icône de suffixe

  // Constructeur
  TextFormBuilder(
      {this.prefix,
      this.suffix,
      this.initialValue,
      this.enabled,
      this.hintText,
      this.textInputType,
      this.controller,
      this.textInputAction,
      this.nextFocusNode,
      this.focusNode,
      this.submitAction,
      this.obscureText = false,
      this.validateFunction,
      this.onSaved,
      this.onChange,
      this.key});

  @override
  _TextFormBuilderState createState() => _TextFormBuilderState();
}

class _TextFormBuilderState extends State<TextFormBuilder> {
  String? error; // Variable pour stocker les erreurs de validation

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 8.0), // Padding horizontal
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Alignement du texte à gauche
        children: [
          CustomCard(
            onTap: () {
              print('clicked'); // Action à l'appui du card
            },
            borderRadius: BorderRadius.circular(40.0), // Arrondi du card
            child: Container(
              color: Theme.of(context).colorScheme.surface, // Couleur du fond
              child: Theme(
                data: ThemeData(
                  primaryColor: Theme.of(context)
                      .colorScheme
                      .secondary, // Couleur principale
                  colorScheme: ColorScheme.fromSwatch().copyWith(
                      secondary: Theme.of(context)
                          .colorScheme
                          .secondary), // Couleur secondaire
                ),
                child: TextFormField(
                  cursorColor: Theme.of(context)
                      .colorScheme
                      .secondary, // Couleur du curseur
                  textCapitalization: TextCapitalization
                      .none, // Pas de capitalisation automatique
                  initialValue: widget.initialValue, // Valeur initiale
                  enabled: widget.enabled, // Activation du champ
                  onChanged: (val) {
                    error = widget.validateFunction!(
                        val); // Validation à chaque changement
                    setState(() {}); // Mise à jour de l'UI
                    widget.onSaved!(val); // Callback onSaved
                  },
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontSize: 15.0, // Taille du texte
                      ),
                  key: widget.key, // Clé du widget
                  controller: widget.controller, // Contrôleur du champ
                  obscureText: widget.obscureText, // Masquer le texte
                  keyboardType: widget.textInputType, // Type de clavier
                  validator: widget.validateFunction, // Fonction de validation
                  onSaved: (val) {
                    error = widget.validateFunction!(
                        val); // Validation lors de la sauvegarde
                    setState(() {}); // Mise à jour de l'UI
                    widget.onSaved!(val!); // Callback onSaved
                  },
                  textInputAction: widget.textInputAction, // Action du clavier
                  focusNode: widget.focusNode, // FocusNode actuel
                  onFieldSubmitted: (String term) {
                    if (widget.nextFocusNode != null) {
                      widget.focusNode!.unfocus(); // Retire le focus actuel
                      FocusScope.of(context).requestFocus(
                          widget.nextFocusNode); // Passe au champ suivant
                    } else {
                      widget.submitAction!(); // Appelle l'action de soumission
                    }
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      widget.prefix, // Icône de préfixe
                      size: 15.0,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    suffixIcon: Icon(
                      widget.suffix, // Icône de suffixe
                      size: 15.0,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surface, // Couleur de fond du champ
                    filled: true, // Remplir le champ
                    hintText: widget.hintText, // Texte indicatif
                    hintStyle: TextStyle(
                      color: Colors.grey[400], // Couleur du texte indicatif
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 20.0), // Padding du texte
                    border: border(context), // Bordure par défaut
                    enabledBorder: border(context), // Bordure quand activé
                    focusedBorder: focusBorder(context), // Bordure quand focus
                    errorStyle: TextStyle(
                        height: 0.0, fontSize: 0.0), // Style des erreurs
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 5.0), // Espacement vertical
          Visibility(
            visible: error != null, // Afficher uniquement si une erreur existe
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0), // Padding à gauche
              child: Text(
                '$error', // Affichage du texte d'erreur
                style: TextStyle(
                  color: Colors.red[700], // Couleur rouge pour l'erreur
                  fontSize: 12.0, // Taille du texte d'erreur
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bordure par défaut
  border(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(30.0), // Rayon arrondi
      ),
      borderSide: BorderSide(
        color: Constants.greenLight2, // Couleur de la bordure
      ),
    );
  }

  // Bordure lorsqu'on focus le champ
  focusBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(30.0), // Rayon arrondi
      ),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.secondary, // Couleur bordure focus
        width: 1.0, // Épaisseur
      ),
    );
  }
}
