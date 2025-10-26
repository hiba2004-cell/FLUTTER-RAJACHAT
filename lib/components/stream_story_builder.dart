import 'package:cloud_firestore/cloud_firestore.dart'; // Importe Firestore pour récupérer les données en temps réel
import 'package:flutter/material.dart'; // Importe Flutter pour construire l’interface utilisateur
import 'package:nurox_chat/widgets/indicators.dart'; // Importe les indicateurs de chargement personnalisés

// Type de fonction pour construire un widget à partir d'un DocumentSnapshot
typedef ItemBuilder<T> = Widget Function(
  BuildContext context,
  DocumentSnapshot doc,
);

// Widget générique pour afficher un flux de stories depuis Firestore
class StreamStoriesWrapper extends StatelessWidget {
  final Stream<QuerySnapshot<Object?>>?
      stream; // Flux Firestore contenant les stories
  final ItemBuilder<DocumentSnapshot>
      itemBuilder; // Fonction pour construire chaque widget story
  final Axis
      scrollDirection; // Direction de défilement (vertical ou horizontal)
  final bool
      shrinkWrap; // Si vrai, la ListView prend seulement la place nécessaire
  final bool? reverse; // Si vrai, inverse l'ordre des items
  final ScrollPhysics physics; // Physique de défilement
  final EdgeInsets padding; // Padding autour de la ListView

  // Constructeur du widget
  const StreamStoriesWrapper({
    Key? key,
    required this.stream,
    required this.itemBuilder,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    this.reverse,
    this.physics = const ClampingScrollPhysics(),
    this.padding = const EdgeInsets.only(bottom: 2.0, left: 2.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // StreamBuilder pour écouter le flux Firestore en temps réel
    return StreamBuilder<QuerySnapshot>(
      stream: stream, // Flux fourni
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Conversion des documents en liste
          var list = snapshot.data!.docs.toList();

          // Si aucune story
          return list.length == 0
              ? SizedBox() // Retourne un widget vide
              : ListView.builder(
                  padding: padding, // Padding autour de la ListView
                  scrollDirection: scrollDirection, // Direction de défilement
                  itemCount: list.length +
                      1, // Nombre d'items + bouton pour ajouter une story
                  shrinkWrap: shrinkWrap, // Ajuste la taille si nécessaire
                  reverse: reverse!, // Inverse l’ordre si true
                  physics: physics, // Physique de défilement
                  itemBuilder: (BuildContext context, int index) {
                    if (index == list.length) {
                      // Dernier item : bouton pour ajouter une story
                      return buildUploadButton();
                    }

                    // Construire chaque widget story
                    return itemBuilder(context, list[index]);
                  },
                );
        } else {
          // Affiche un indicateur de chargement si les données ne sont pas encore disponibles
          return circularProgress(context);
        }
      },
    );
  }

  // Widget pour afficher le bouton d'ajout de story
  buildUploadButton() {
    return Padding(
      padding: EdgeInsets.all(7.0), // Padding autour du bouton
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue, // Couleur de fond du conteneur
          shape: BoxShape.circle, // Forme circulaire
          border: Border.all(
            color: Colors.transparent, // Bordure transparente
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3), // Ombre légère
              offset: new Offset(0.0, 0.0),
              blurRadius: 2.0,
              spreadRadius: 0.0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(0.5), // Padding interne
          child: CircleAvatar(
            radius: 25.0, // Rayon du cercle
            backgroundColor: Colors.grey[300], // Couleur de fond du cercle
            child: Center(
              child: Icon(Icons.add, color: Colors.blue), // Icône "+"
            ),
          ),
        ),
      ),
    );
  }
}
