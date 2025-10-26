import 'package:flutter/material.dart'; // Importe Flutter pour construire l’interface utilisateur
import 'package:ionicons/ionicons.dart'; // Importe Ionicons pour utiliser des icônes
import 'package:nurox_chat/components/custom_card.dart'; // Importe le composant CustomCard
import 'package:nurox_chat/utils/constants.dart'; // Importe les constantes personnalisées (ex. couleurs)

// Widget PasswordFormBuilder : champ de mot de passe personnalisable avec visibilité
class PasswordFormBuilder extends StatefulWidget {
  // Valeur initiale du champ
  final String? initialValue;

  // Détermine si le champ est activé ou désactivé
  final bool? enabled;

  // Texte indicatif du champ
  final String? hintText;

  // Type de saisie du clavier
  final TextInputType? textInputType;

  // Contrôleur pour manipuler le texte
  final TextEditingController? controller;

  // Action lors de la validation du champ
  final TextInputAction? textInputAction;

  // Focus actuel et focus suivant
  final FocusNode? focusNode, nextFocusNode;

  // Action à exécuter lors de la soumission
  final VoidCallback? submitAction;

  // Masque le texte ou non
  final bool obscureText;

  // Fonction de validation du champ
  final FormFieldValidator<String>? validateFunction;

  // Fonction appelée lors de l’enregistrement ou changement du texte
  final void Function(String)? onSaved, onChange;

  // Clé du widget
  final Key? key;

  // Icône au début du champ
  final IconData? prefix;

  // Icône à la fin du champ (ex. pour afficher/masquer le mot de passe)
  final IconData? suffix;

  // Constructeur avec paramètres optionnels et obligatoires
  PasswordFormBuilder(
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
      this.obscureText = true,
      this.validateFunction,
      this.onSaved,
      this.onChange,
      this.key});

  @override
  _PasswordFormBuilderState createState() =>
      _PasswordFormBuilderState(); // Création de l’état associé
}

// État du widget PasswordFormBuilder
class _PasswordFormBuilderState extends State<PasswordFormBuilder> {
  // Variable pour stocker le message d’erreur
  String? error;

  // Détermine si le texte est masqué
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 8.0), // Espacement horizontal
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Aligne les éléments à gauche
        children: [
          CustomCard(
            onTap: () {
              print(
                  'clicked'); // Affiche un message dans la console lors du clic
            },
            borderRadius:
                BorderRadius.circular(40.0), // Coins arrondis du CustomCard
            child: Container(
              child: Theme(
                data: ThemeData(
                  primaryColor: Theme.of(context)
                      .colorScheme
                      .secondary, // Couleur principale du thème
                  colorScheme: ColorScheme.fromSwatch().copyWith(
                      secondary: Theme.of(context)
                          .colorScheme
                          .secondary), // Couleur secondaire du thème
                ),
                child: TextFormField(
                  initialValue: widget.initialValue, // Valeur initiale du champ
                  enabled: widget.enabled, // Active ou désactive le champ
                  onChanged: (val) {
                    error =
                        widget.validateFunction!(val); // Met à jour l’erreur
                    widget.onSaved!(val); // Appelle la fonction onSaved
                  },
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontSize: 15.0, // Taille du texte
                      ),
                  key: widget.key, // Clé du champ
                  controller: widget.controller, // Contrôleur du texte
                  obscureText: obscureText, // Masque ou affiche le texte
                  keyboardType: widget.textInputType, // Type de clavier
                  validator: widget.validateFunction, // Fonction de validation
                  onSaved: (val) {
                    error =
                        widget.validateFunction!(val); // Met à jour l’erreur
                    widget.onSaved!(val!); // Sauvegarde la valeur
                  },
                  textInputAction: widget.textInputAction, // Action du clavier
                  focusNode: widget.focusNode, // Focus actuel
                  onFieldSubmitted: (String term) {
                    if (widget.nextFocusNode != null) {
                      widget.focusNode!.unfocus(); // Retire le focus actuel
                      FocusScope.of(context).requestFocus(
                          widget.nextFocusNode); // Passe au focus suivant
                    } else {
                      widget
                          .submitAction!(); // Sinon, exécute l’action de soumission
                    }
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      widget.prefix, // Icône au début du champ
                      size: 15.0,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() => obscureText =
                            !obscureText); // Alterne la visibilité du texte
                      },
                      child: Icon(
                        obscureText
                            ? widget.suffix
                            : Ionicons
                                .eye_off_outline, // Change l’icône selon l’état
                        size: 15.0,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    hintText: widget.hintText, // Texte indicatif
                    filled: true, // Remplit le champ avec une couleur
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surface, // Couleur de fond du champ
                    hintStyle: TextStyle(
                      color: Colors.grey[400], // Couleur du texte indicatif
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 20.0), // Espacement interne
                    border: border(context), // Bordure normale
                    enabledBorder:
                        border(context), // Bordure lorsque le champ est activé
                    focusedBorder:
                        focusBorder(context), // Bordure lorsqu’il est focus
                    errorStyle: TextStyle(
                        height: 0.0,
                        fontSize: 0.0), // Masque le texte d’erreur natif
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 5.0), // Espacement vertical
          Visibility(
            visible: error !=
                null, // Affiche le message d’erreur uniquement si existant
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0), // Espacement à gauche
              child: Text(
                '$error', // Texte d’erreur
                style: TextStyle(
                  color: Colors.red[700], // Couleur rouge
                  fontSize: 12.0, // Taille du texte
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bordure normale du champ
  border(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(30.0), // Coins arrondis
      ),
      borderSide: BorderSide(
        color: Constants.darkAccent, // Couleur de la bordure
      ),
    );
  }

  // Bordure lorsque le champ est focus
  focusBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(30.0), // Coins arrondis
      ),
      borderSide: BorderSide(
        color: Constants.greenLight2, // Couleur verte
        width: 1.0, // Épaisseur de la bordure
      ),
    );
  }
}
