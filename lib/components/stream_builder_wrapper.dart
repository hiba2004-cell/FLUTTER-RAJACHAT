import 'package:cloud_firestore/cloud_firestore.dart'; // Importe Firestore pour accéder aux données en temps réel
import 'package:flutter/material.dart'; // Importe Flutter pour construire l’interface utilisateur
import 'package:nurox_chat/widgets/indicators.dart'; // Importe les indicateurs de chargement personnalisés

// Définition d’un type générique pour construire les éléments à partir d’un DocumentSnapshot
typedef ItemBuilder<T> = Widget Function(
  BuildContext context,
  DocumentSnapshot doc,
);

// Widget StreamBuilderWrapper : enveloppe un StreamBuilder pour Firestore
class StreamBuilderWrapper extends StatelessWidget {
  // Flux de données à écouter
  final Stream<QuerySnapshot<Object?>>? stream;

  // Fonction pour construire chaque élément
  final ItemBuilder<DocumentSnapshot> itemBuilder;

  // Direction de défilement (vertical ou horizontal)
  final Axis scrollDirection;

  // Détermine si la ListView prend juste la place nécessaire ou tout l’espace disponible
  final bool shrinkWrap;

  // Physique du défilement
  final ScrollPhysics physics;

  // Espacement autour de la ListView
  final EdgeInsets padding;

  // Requête optionnelle pour Firestore
  final Query? query;

  // Constructeur avec paramètres optionnels et obligatoires
  const StreamBuilderWrapper({
    Key? key,
    required this.stream,
    required this.itemBuilder,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    this.query,
    this.physics = const ClampingScrollPhysics(),
    this.padding = const EdgeInsets.only(bottom: 2.0, left: 2.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream, // Écoute le flux de données
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var list =
              snapshot.data!.docs.toList(); // Convertit les documents en liste
          return list.length == 0 // Si la liste est vide
              ? Padding(
                  padding: const EdgeInsets.only(
                      top: 100.0), // Ajoute un espacement vertical
                  child: Container(
                    height: 60.0,
                    width: 100.0,
                    child: Center(
                      child: Text(
                          'No Posts'), // Message lorsque aucun post n’est disponible
                    ),
                  ),
                )
              : ListView.builder(
                  // Sinon, construit la liste des éléments
                  padding: padding, // Ajoute l’espacement autour de la liste
                  scrollDirection:
                      scrollDirection, // Définit la direction de défilement
                  itemCount: list.length, // Nombre d’éléments
                  shrinkWrap:
                      shrinkWrap, // Détermine si la ListView prend tout l’espace
                  physics: physics, // Définit le comportement du défilement
                  itemBuilder: (BuildContext context, int index) {
                    return itemBuilder(
                        context,
                        list[
                            index]); // Construit chaque élément avec itemBuilder
                  },
                );
        } else {
          return circularProgress(
              context); // Affiche un indicateur de chargement si les données ne sont pas encore disponibles
        }
      },
    );
  }
}
