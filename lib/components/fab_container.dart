// Importation du package d’animations pour créer des transitions fluides entre les écrans
import 'package:animations/animations.dart';
// Importation des widgets Cupertino (style iOS)
import 'package:flutter/cupertino.dart';
// Importation du package Flutter pour utiliser les widgets Material Design
import 'package:flutter/material.dart';
// Importation du package Provider pour la gestion d’état
import 'package:provider/provider.dart';
// Importation du ViewModel qui gère les statuts (StatusViewModel)
import 'package:nurox_chat/view_models/status/status_view_model.dart';
// Importation de la page pour créer un post
import '../posts/create_post.dart';

// Déclaration d’un widget stateless appelé FabContainer (Floating Action Button personnalisé)
class FabContainer extends StatelessWidget {
  // La page qui sera ouverte lorsque l’utilisateur clique
  final Widget? page;

  // L’icône du bouton flottant
  final IconData icon;

  // Détermine si le bouton est petit (mini) ou non
  final bool mini;

  // Constructeur de la classe
  FabContainer({this.page, required this.icon, this.mini = false});

  // Méthode build pour construire l’arborescence du widget
  @override
  Widget build(BuildContext context) {
    // Récupération du ViewModel à partir du Provider
    StatusViewModel viewModel = Provider.of<StatusViewModel>(context);

    // OpenContainer permet de créer une animation entre le bouton et la page ouverte
    return OpenContainer(
      // Type de transition : fondu (fade)
      transitionType: ContainerTransitionType.fade,

      // Contenu à afficher lorsque le conteneur s’ouvre (la nouvelle page)
      openBuilder: (BuildContext context, VoidCallback _) {
        return page!;
      },

      // Élévation (ombre) du bouton lorsqu’il est fermé
      closedElevation: 4.0,

      // Forme du bouton fermé (cercle)
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(56 / 2),
        ),
      ),

      // Couleur du bouton fermé
      closedColor: Theme.of(context).scaffoldBackgroundColor,

      // Contenu affiché quand le conteneur est fermé (le bouton flottant)
      closedBuilder: (BuildContext context, VoidCallback openContainer) {
        return FloatingActionButton(
          // Couleur du bouton
          backgroundColor: Theme.of(context).primaryColor,

          // Icône du bouton
          child: Icon(
            icon,
            color: Colors.white,
          ),

          // Action au clic : appelle la méthode chooseUpload
          onPressed: () {
            chooseUpload(context, viewModel);
          },

          // Taille du bouton (mini ou normal)
          mini: mini,
        );
      },
    );
  }

  // Méthode pour afficher une feuille modale (bottom sheet) avec des options d’upload
  chooseUpload(BuildContext context, StatusViewModel viewModel) {
    return showModalBottomSheet(
      context: context, // contexte actuel
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // coins arrondis
      ),

      // Contenu de la feuille modale
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: .4, // hauteur de la feuille (40% de l’écran)
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // alignement à gauche
            children: [
              SizedBox(height: 20.0), // espace en haut

              // Titre centré : "Choose Upload"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Center(
                  child: Text(
                    'Choose Upload',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ),

              Divider(), // ligne de séparation

              // Première option : créer un post
              ListTile(
                leading: Icon(
                  CupertinoIcons.camera_on_rectangle,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 25.0,
                ),
                title: Text(
                  'Make a post',
                ),
                onTap: () {
                  // Ferme la feuille modale
                  Navigator.pop(context);

                  // Ouvre la page CreatePost via une transition iOS
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => CreatePost(),
                    ),
                  );
                },
              ),

              // Deuxième option : ajouter une story
              ListTile(
                leading: Icon(
                  CupertinoIcons.camera_on_rectangle,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 25.0,
                ),
                title: Text('Add to story'),
                onTap: () async {
                  // Appelle la méthode pour choisir une image
                  await viewModel.pickImage(context: context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
