import 'package:cloud_firestore/cloud_firestore.dart'; // Importe la bibliothèque Firestore pour accéder aux données en temps réel
import 'package:flutter/material.dart'; // Importe Flutter pour construire l’interface utilisateur
import 'package:nurox_chat/widgets/indicators.dart'; // Importe un widget personnalisé (ex. : indicateur de chargement)

// Déclare un alias de fonction générique nommé ItemBuilder qui prend un contexte et un document Firestore, et retourne un Widget
typedef ItemBuilder<T> = Widget Function(
  BuildContext context,
  DocumentSnapshot doc,
);

// Classe ActivityStreamWrapper : un widget stateless qui écoute un flux de données Firestore et affiche une liste dynamique
class ActivityStreamWrapper extends StatelessWidget {
  // Flux Firestore contenant les données à écouter (peut être nul)
  final Stream<QuerySnapshot<Object?>>? stream;

  // Fonction de construction d’un élément de liste à partir d’un document Firestore
  final ItemBuilder<DocumentSnapshot> itemBuilder;

  // Direction du défilement (verticale par défaut)
  final Axis scrollDirection;

  // Définit si la ListView doit s’adapter à son contenu
  final bool shrinkWrap;

  // Détermine le comportement du défilement (ici, ClampingScrollPhysics pour Android)
  final ScrollPhysics physics;

  // Définit les marges internes (espacement autour de la liste)
  final EdgeInsets padding;

  // Constructeur de la classe avec ses paramètres et valeurs par défaut
  const ActivityStreamWrapper({
    Key? key,
    required this.stream,
    required this.itemBuilder,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    this.physics = const ClampingScrollPhysics(),
    this.padding = const EdgeInsets.only(bottom: 2.0, left: 2.0),
  }) : super(key: key);

  // Méthode de construction du widget
  @override
  Widget build(BuildContext context) {
    // Utilise StreamBuilder pour écouter les changements de données dans Firestore
    return StreamBuilder<QuerySnapshot>(
      stream: stream, // Le flux Firestore à écouter
      builder: (context, snapshot) {
        // Si des données sont disponibles
        if (snapshot.hasData) {
          // Convertit les documents reçus en liste
          var list = snapshot.data!.docs.toList();

          // Si la liste est vide, affiche un message indiquant qu’il n’y a pas d’activités
          return list.length == 0
              ? Container(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 250.0),
                      child:
                          Text('No Recent Activities'), // Texte d’information
                    ),
                  ),
                )
              // Sinon, affiche la liste des activités
              : ListView.separated(
                  // Définit un séparateur entre les éléments de la liste
                  separatorBuilder: (BuildContext context, int index) {
                    return Align(
                      alignment: Alignment
                          .centerRight, // Aligne le séparateur à droite
                      child: Container(
                        height: 0.5, // Épaisseur de la ligne
                        width: MediaQuery.of(context).size.width /
                            1.3, // Largeur relative à l’écran
                        child: const Divider(), // Ligne de séparation
                      ),
                    );
                  },
                  padding: padding, // Ajoute un espacement à la liste
                  scrollDirection:
                      scrollDirection, // Définit la direction du défilement
                  itemCount: list.length, // Nombre d’éléments dans la liste
                  shrinkWrap:
                      shrinkWrap, // Définit si la taille de la liste s’adapte à son contenu
                  physics: physics, // Définit le comportement du défilement
                  itemBuilder: (BuildContext context, int index) {
                    // Construit chaque élément en utilisant la fonction passée en paramètre
                    return itemBuilder(context, list[index]);
                  },
                );
        } else {
          // Si aucune donnée n’est encore chargée, affiche un indicateur de chargement
          return circularProgress(context);
        }
      },
    );
  }
}
