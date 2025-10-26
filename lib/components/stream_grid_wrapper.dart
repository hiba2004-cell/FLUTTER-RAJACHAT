import 'package:cloud_firestore/cloud_firestore.dart'; // Importe Firestore pour accéder aux données en temps réel
import 'package:flutter/material.dart'; // Importe Flutter pour construire l’interface utilisateur
import 'package:nurox_chat/widgets/indicators.dart'; // Importe les indicateurs de chargement personnalisés

// Type de fonction pour construire un widget à partir d'un DocumentSnapshot
typedef ItemBuilder<T> = Widget Function(
  BuildContext context,
  DocumentSnapshot doc,
);

// Widget générique pour afficher un flux Firestore sous forme de GridView
class StreamGridWrapper extends StatelessWidget {
  final Stream<QuerySnapshot<Object?>>?
      stream; // Flux Firestore contenant les documents
  final ItemBuilder<DocumentSnapshot>
      itemBuilder; // Fonction pour construire chaque widget
  final Axis
      scrollDirection; // Direction de défilement (vertical ou horizontal)
  final bool
      shrinkWrap; // Si vrai, GridView prend seulement la place nécessaire
  final ScrollPhysics physics; // Physique de défilement
  final EdgeInsets padding; // Padding autour de la GridView

  // Constructeur du widget
  const StreamGridWrapper({
    Key? key,
    required this.stream,
    required this.itemBuilder,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    this.physics = const ClampingScrollPhysics(),
    this.padding = const EdgeInsets.only(bottom: 2.0, left: 2.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Utilisation de StreamBuilder pour écouter le flux Firestore en temps réel
    return StreamBuilder<QuerySnapshot>(
      stream: stream, // Flux fourni
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Conversion des documents en liste
          var list = snapshot.data!.docs.toList();

          // Si aucun document
          return list.length == 0
              ? Container(
                  child: Center(
                    child: Text('No Posts'), // Message "aucun post"
                  ),
                )
              : GridView.builder(
                  padding: padding, // Padding autour de la GridView
                  scrollDirection: scrollDirection, // Direction de défilement
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Nombre de colonnes
                    childAspectRatio:
                        3 / 3, // Rapport largeur/hauteur des items
                  ),
                  itemCount: list.length, // Nombre d'items
                  shrinkWrap: shrinkWrap, // Ajuste la taille si nécessaire
                  physics: physics, // Physique de défilement
                  itemBuilder: (BuildContext context, int index) {
                    return itemBuilder(
                        context, list[index]); // Construire chaque widget
                  },
                );
        } else {
          // Affiche un indicateur de chargement si les données ne sont pas encore disponibles
          return circularProgress(context);
        }
      },
    );
  }
}
