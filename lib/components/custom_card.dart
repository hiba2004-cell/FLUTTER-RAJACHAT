// Importation du package Flutter pour utiliser les widgets et le matériel visuel
import 'package:flutter/material.dart';

// Déclaration d'une classe stateless (immuable) appelée CustomCard
class CustomCard extends StatelessWidget {
  // Le widget enfant à afficher à l’intérieur de la carte (ex: texte, image, etc.)
  final Widget? child;

  // Fonction appelée lorsque l’utilisateur appuie sur la carte
  final Function() onTap;

  // Définit les coins arrondis de la carte (facultatif)
  final BorderRadius? borderRadius;

  // Constructeur de la classe CustomCard
  CustomCard({
    Key? key, // clé optionnelle pour identifier le widget
    required this.child, // paramètre obligatoire : contenu de la carte
    required this.onTap, // paramètre obligatoire : action lors du clic
    this.borderRadius, // paramètre optionnel : arrondi des coins
  });

  // Méthode build : construit l’arborescence du widget
  @override
  Widget build(BuildContext context) {
    return Container(
      // Définit la couleur d’arrière-plan comme transparente
      color: Colors.transparent,

      // Le widget Material permet d’avoir des effets visuels du style Material Design
      child: Material(
        // Définit le type de matériau comme transparent (pas de couleur de fond)
        type: MaterialType.transparency,

        // Définit la couleur de fond comme transparente
        color: Colors.transparent,

        // Applique le rayon de bordure si spécifié
        borderRadius: borderRadius,

        // InkWell permet de détecter les clics et d’afficher l’effet d’onde (ripple effect)
        child: InkWell(
          // Donne la même bordure arrondie à l’effet d’onde
          borderRadius: borderRadius,

          // Action à exécuter lors du clic sur la carte
          onTap: onTap,

          // Contenu à afficher à l’intérieur de la carte
          child: child,
        ),
      ),
    );
  }
}
