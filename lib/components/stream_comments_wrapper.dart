import 'package:cloud_firestore/cloud_firestore.dart'; // Importe Firestore pour accéder aux données en temps réel
import 'package:flutter/material.dart'; // Importe Flutter pour construire l’interface utilisateur
import 'package:nurox_chat/widgets/indicators.dart'; // Importe les indicateurs de chargement personnalisés

// Type de fonction pour construire un widget à partir d'un DocumentSnapshot
typedef ItemBuilder<T> = Widget Function(
  BuildContext context,
  DocumentSnapshot doc,
);

// Widget générique pour afficher un flux de commentaires à partir d'un Stream Firestore
class CommentsStreamWrapper extends StatelessWidget {
  final Stream<QuerySnapshot<Object?>>?
      stream; // Stream de commentaires provenant de Firestore
  final ItemBuilder<DocumentSnapshot>
      itemBuilder; // Fonction pour construire un widget pour chaque commentaire
  final Axis
      scrollDirection; // Direction de défilement (vertical ou horizontal)
  final bool
      shrinkWrap; // Si vrai, la ListView prend seulement la place nécessaire
  final ScrollPhysics physics; // Physique de défilement
  final EdgeInsets padding; // Padding autour de la ListView

  // Constructeur du widget
  const CommentsStreamWrapper({
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
    // Utilisation d'un StreamBuilder pour écouter le flux de commentaires en temps réel
    return StreamBuilder<QuerySnapshot>(
      stream: stream, // Flux fourni depuis Firestore
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Conversion des documents en liste
          var list = snapshot.data!.docs.toList();

          // Si aucun commentaire
          return list.length == 0
              ? Container(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 20.0), // Ajoute un espacement en haut
                      child:
                          Text('No comments'), // Message "pas de commentaires"
                    ),
                  ),
                )
              : ListView.separated(
                  // Séparateur entre chaque commentaire
                  separatorBuilder: (BuildContext context, int index) {
                    return Align(
                      alignment:
                          Alignment.centerRight, // Alignement du séparateur
                      child: Container(
                        height: 0.5, // Hauteur du séparateur
                        width: MediaQuery.of(context).size.width /
                            1.3, // Largeur du séparateur
                        child: const Divider(), // Ligne séparatrice fine
                      ),
                    );
                  },
                  reverse:
                      true, // Les commentaires les plus récents apparaissent en haut
                  padding: padding, // Padding autour de la ListView
                  scrollDirection: scrollDirection, // Direction de défilement
                  itemCount: list.length, // Nombre de commentaires
                  shrinkWrap: shrinkWrap, // Ajuste la taille si nécessaire
                  physics: physics, // Physique de défilement
                  itemBuilder: (BuildContext context, int index) {
                    return itemBuilder(context,
                        list[index]); // Construire chaque widget commentaire
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
