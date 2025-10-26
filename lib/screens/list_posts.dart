import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nurox_chat/models/post.dart';
import 'package:nurox_chat/utils/firebase.dart';
import 'package:nurox_chat/widgets/indicators.dart';
import 'package:nurox_chat/widgets/userpost.dart';

/// Écran affichant la liste de tous les posts d'un utilisateur spécifique
/// Utilisé pour voir l'historique complet des publications d'un profil
class ListPosts extends StatefulWidget {
  /// ID de l'utilisateur dont on veut afficher les posts
  final userId;

  /// Nom d'utilisateur à afficher dans l'AppBar
  final username;

  const ListPosts({Key? key, required this.userId, required this.username})
      : super(key: key);

  @override
  State<ListPosts> createState() => _ListPostsState();
}

class _ListPostsState extends State<ListPosts> {
  /// Construit l'interface de la liste des posts
  /// 
  /// AFFICHAGE :
  /// - AppBar avec :
  ///   * Bouton retour (chevron_back) à gauche
  ///   * Username en MAJUSCULES en gris (12px)
  ///   * Titre "Posts" en gras (18px)
  /// - Body : Liste scrollable des posts
  /// 
  /// ÉTATS D'AFFICHAGE :
  /// 1. Chargement : Indicateur circulaire de progression
  /// 2. Données présentes : Liste des posts avec padding 10px
  /// 3. Pas de posts : Message "No Feeds" centré (26px, gras)
  /// 
  /// COMPORTEMENT :
  /// - FutureBuilder charge les posts depuis Firestore
  /// - Tri par timestamp décroissant (plus récents en premier)
  /// - Filtre par ownerId = userId de l'utilisateur
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        /// Bouton de retour personnalisé
        /// AFFICHAGE : Icône chevron gauche cliquable
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(Ionicons.chevron_back),
        ),
        /// Titre de l'AppBar sur 2 lignes
        /// AFFICHAGE :
        /// - Ligne 1 : USERNAME en majuscules, gris, 12px, semi-gras
        /// - Ligne 2 : "Posts" en noir, 18px, gras
        title: Column(
          children: [
            Text(
              widget.username.toUpperCase(),
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            Text(
              'Posts',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        /// Container plein écran pour la liste
        /// AFFICHAGE : Prend toute la hauteur et largeur disponibles
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: FutureBuilder(
          /// Requête Firestore pour récupérer les posts
          /// COMPORTEMENT :
          /// - Filtre : Seulement les posts de cet utilisateur (ownerId)
          /// - Tri : Par timestamp décroissant (plus récents en premier)
          /// - Exécution unique au build (FutureBuilder)
          future: postRef
              .where('ownerId', isEqualTo: widget.userId)
              .orderBy('timestamp', descending: true)
              .get(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            /// CAS 1 : Données chargées avec succès
            /// AFFICHAGE : ListView des posts avec padding 10px entre chaque
            if (snapshot.hasData) {
              var snap = snapshot.data;
              List docs = snap!.docs;
              return ListView.builder(
                itemCount: docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  // Conversion du document Firestore en modèle PostModel
                  PostModel posts = PostModel.fromJson(docs[index].data());
                  /// Chaque post avec padding de 10px tout autour
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: UserPost(post: posts),
                  );
                },
              );
            } 
            /// CAS 2 : Chargement en cours
            /// AFFICHAGE : Indicateur circulaire de progression centré
            else if (snapshot.connectionState == ConnectionState.waiting) {
              return circularProgress(context);
            } 
            /// CAS 3 : Pas de données ou erreur
            /// AFFICHAGE : Message "No Feeds" centré
            /// - Texte de 26px en gras
            /// - Centré verticalement et horizontalement
            else
              return Center(
                child: Text(
                  'No Feeds',
                  style: TextStyle(
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
          },
        ),
      ),
    );
  }
}