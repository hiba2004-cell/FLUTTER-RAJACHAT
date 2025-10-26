// Importation du package Flutter pour utiliser les widgets et composants visuels
import 'package:flutter/material.dart';

// Définition d'une classe stateless (immuable) appelée CustomImage
class CustomImage extends StatelessWidget {
  // URL (ou chemin local) de l'image à afficher
  final String? imageUrl;

  // Hauteur de l'image (par défaut 100 pixels)
  final double height;

  // Largeur de l'image (par défaut prend toute la largeur disponible)
  final double width;

  // Détermine comment l’image doit être ajustée à son conteneur (ex : couvrir, contenir…)
  final BoxFit fit;

  // Constructeur de la classe CustomImage
  CustomImage({
    this.imageUrl, // chemin de l'image (facultatif)
    this.height = 100.0, // hauteur par défaut
    this.width = double.infinity, // largeur par défaut (prend toute la largeur)
    this.fit =
        BoxFit.cover, // mode d'ajustement par défaut (couvre tout l’espace)
  });

  // Méthode build qui construit et renvoie le widget Image
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imageUrl ?? '', // affiche l'image si le chemin existe, sinon chaîne vide
      height: height, // définit la hauteur de l’image
      width: width, // définit la largeur de l’image
      fit: fit, // ajuste l’image selon le mode spécifié

      // Gestion d’erreur : si l’image ne se charge pas, affiche une icône d’erreur
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.error);
      },
    );
  }
}
