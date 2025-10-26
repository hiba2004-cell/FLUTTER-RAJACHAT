import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:like_button/like_button.dart';
import 'package:nurox_chat/components/stream_comments_wrapper.dart';
import 'package:nurox_chat/models/comments.dart';
import 'package:nurox_chat/models/post.dart';
import 'package:nurox_chat/models/user.dart';
import 'package:nurox_chat/services/post_service.dart';
import 'package:nurox_chat/utils/firebase.dart';
// import 'package:nurox_chat/widgets/cached_image.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Écran d'affichage des commentaires d'un post
/// Permet de voir les commentaires existants et d'en ajouter de nouveaux
class Comments extends StatefulWidget {
  final PostModel? post;

  Comments({this.post});

  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  UserModel? user;

  PostService services = PostService();
  final DateTime timestamp = DateTime.now();
  TextEditingController commentsTEC = TextEditingController();

  /// Retourne l'UID de l'utilisateur connecté
  currentUserId() {
    return firebaseAuth.currentUser!.uid;
  }

  /// Construit l'interface principale de l'écran des commentaires
  ///
  /// AFFICHAGE :
  /// - AppBar avec icône X pour fermer et titre "Comments"
  /// - Zone scrollable contenant :
  ///   * Le post complet (image + description + likes)
  ///   * Divider (séparateur) de 1.5px
  ///   * Liste des commentaires en temps réel
  /// - Champ de saisie fixe en bas de l'écran avec bouton d'envoi
  ///
  /// STRUCTURE :
  /// - Hauteur totale = hauteur de l'écran
  /// - Column avec Flexible pour la liste et Align pour le champ de saisie
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            CupertinoIcons.xmark_circle_fill,
          ),
        ),
        centerTitle: true,
        title: Text('Comments'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            /// Zone scrollable : Post + Commentaires
            Flexible(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: buildFullPost(),
                  ),
                  Divider(thickness: 1.5),
                  buildComments()
                ],
              ),
            ),

            /// Zone fixe en bas : Champ de saisie du commentaire
            /// AFFICHAGE :
            /// - Padding de 20px tout autour
            /// - Hauteur max de 190px
            /// - TextField avec bordures arrondies (5px)
            /// - Icône send pour envoyer le commentaire
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: 190.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Flexible(
                        child: ListTile(
                          contentPadding: EdgeInsets.all(0),
                          title: TextField(
                            textCapitalization: TextCapitalization.sentences,
                            controller: commentsTEC,
                            style: TextStyle(
                              fontSize: 15.0,
                              color:
                                  Theme.of(context).textTheme.titleLarge!.color,
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10.0),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              hintText: "Write your comment...",
                              hintStyle: TextStyle(
                                fontSize: 15.0,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .color,
                              ),
                            ),
                            maxLines: null,
                          ),

                          /// Bouton d'envoi du commentaire
                          /// COMPORTEMENT : Upload le commentaire puis vide le champ
                          trailing: GestureDetector(
                            onTap: () async {
                              await services.uploadComment(
                                currentUserId(),
                                commentsTEC.text,
                                widget.post!.postId!,
                                widget.post!.ownerId!,
                                widget.post!.mediaUrl!,
                              );
                              commentsTEC.clear();
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Icon(
                                Icons.send,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit l'affichage complet du post
  ///
  /// AFFICHAGE :
  /// - Image du post : 350px de hauteur, largeur = écran - 20px
  /// - Description en gras
  /// - Timeago (ex: "il y a 2 heures")
  /// - Nombre de likes en temps réel (StreamBuilder)
  /// - Bouton like animé à droite
  ///
  /// DISPOSITION :
  /// - Column avec image en haut
  /// - Row en bas avec infos à gauche et bouton like à droite
  buildFullPost() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Image du post
        /// AFFICHAGE : 350px de haut, largeur adaptative
        Container(
          height: 350.0,
          width: MediaQuery.of(context).size.width - 20.0,
          child: Image.asset(widget.post!.mediaUrl!),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Description du post
                  /// AFFICHAGE : Texte en gras (w800)
                  Text(
                    widget.post!.description!,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    children: [
                      /// Timeago (temps écoulé)
                      /// AFFICHAGE : Format relatif (ex: "2 hours ago")
                      Text(
                        timeago.format(widget.post!.timestamp!.toDate()),
                        style: TextStyle(),
                      ),
                      SizedBox(width: 3.0),

                      /// Nombre de likes en temps réel
                      /// COMPORTEMENT : Écoute les changements via StreamBuilder
                      StreamBuilder(
                        stream: likesRef
                            .where('postId', isEqualTo: widget.post!.postId)
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData) {
                            QuerySnapshot snap = snapshot.data!;
                            List<DocumentSnapshot> docs = snap.docs;
                            return buildLikesCount(context, docs.length ?? 0);
                          } else {
                            return buildLikesCount(context, 0);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Spacer(),
              buildLikeButton(),
            ],
          ),
        ),
      ],
    );
  }

  /// Construit la liste des commentaires en temps réel
  ///
  /// AFFICHAGE :
  /// - Liste scrollable avec StreamBuilder
  /// - Chaque commentaire affiche :
  ///   * Avatar circulaire (40px de diamètre)
  ///   * Username en gras (14px)
  ///   * Timeago en petit (10px)
  ///   * Texte du commentaire avec padding gauche de 60px
  ///
  /// COMPORTEMENT :
  /// - Tri par timestamp décroissant (plus récents en premier)
  /// - Mise à jour automatique via stream Firestore
  /// - Scroll désactivé (NeverScrollableScrollPhysics) car dans un ListView parent
  buildComments() {
    return CommentsStreamWrapper(
      shrinkWrap: true,
      stream: commentRef
          .doc(widget.post!.postId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (_, DocumentSnapshot snapshot) {
        CommentModel comments =
            CommentModel.fromJson(snapshot.data() as Map<String, dynamic>);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// Avatar de l'auteur du commentaire
                  /// AFFICHAGE : Cercle de 40px (radius 20px)
                  CircleAvatar(
                    radius: 20.0,
                    backgroundImage: AssetImage(comments.userDp!),
                    backgroundColor: Colors.transparent,
                  ),
                  SizedBox(width: 10.0),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Nom d'utilisateur
                      /// AFFICHAGE : Texte en gras, taille 14px
                      Text(
                        comments.username!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),

                      /// Temps écoulé depuis le commentaire
                      /// AFFICHAGE : Petit texte gris, taille 10px
                      Text(
                        timeago.format(comments.timestamp!.toDate()),
                        style: TextStyle(fontSize: 10.0),
                      ),
                    ],
                  )
                ],
              ),

              /// Texte du commentaire
              /// AFFICHAGE : Padding gauche de 60px pour alignement avec username
              Padding(
                padding: const EdgeInsets.only(left: 60.0),
                child: Text(comments.comment!.trim()),
              ),
              SizedBox(height: 10.0),
            ],
          ),
        );
      },
    );
  }

  /// Construit le bouton like animé avec état en temps réel
  ///
  /// AFFICHAGE :
  /// - Bouton like animé (25px)
  /// - Icône vide (heart_outline) si pas liké, couleur grise
  /// - Icône pleine (heart) si liké, couleur rouge
  /// - Animation de bulles colorées lors du like
  /// - Animation circulaire rose à rouge
  ///
  /// COMPORTEMENT :
  /// - StreamBuilder écoute l'état du like en temps réel
  /// - onTap : Ajoute/retire le like de Firestore
  /// - Ajoute/retire la notification au propriétaire du post
  /// - Retourne l'état inversé pour l'animation
  buildLikeButton() {
    return StreamBuilder(
      stream: likesRef
          .where('postId', isEqualTo: widget.post!.postId)
          .where('userId', isEqualTo: currentUserId())
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];

          /// Gestion du tap sur le bouton like
          /// COMPORTEMENT :
          /// - Si pas liké : Ajoute dans Firestore + notification
          /// - Si déjà liké : Supprime de Firestore + notification
          Future<bool> onLikeButtonTapped(bool isLiked) async {
            if (docs.isEmpty) {
              likesRef.add({
                'userId': currentUserId(),
                'postId': widget.post!.postId,
                'dateCreated': Timestamp.now(),
              });
              addLikesToNotification();
              return !isLiked;
            } else {
              likesRef.doc(docs[0].id).delete();
              removeLikeFromNotification();
              return isLiked;
            }
          }

          /// Bouton like avec animations
          /// AFFICHAGE :
          /// - Taille : 25px
          /// - Couleurs bulles : Orange, rouge, rose, orange foncé
          /// - Couleur cercle : Rose à rouge
          return LikeButton(
            onTap: onLikeButtonTapped,
            size: 25.0,
            circleColor:
                CircleColor(start: Color(0xffFFC0CB), end: Color(0xffff0000)),
            bubblesColor: BubblesColor(
                dotPrimaryColor: Color(0xffFFA500),
                dotSecondaryColor: Color(0xffd8392b),
                dotThirdColor: Color(0xffFF69B4),
                dotLastColor: Color(0xffff8c00)),
            likeBuilder: (bool isLiked) {
              return Icon(
                docs.isEmpty ? Ionicons.heart_outline : Ionicons.heart,
                color: docs.isEmpty ? Colors.grey : Colors.red,
                size: 25,
              );
            },
          );
        }
        return Container();
      },
    );
  }

  /// Affiche le nombre de likes
  ///
  /// AFFICHAGE :
  /// - Texte en gras, taille 10px
  /// - Padding gauche de 7px
  /// - Format : "X likes"
  buildLikesCount(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.only(left: 7.0),
      child: Text(
        '$count likes',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10.0,
        ),
      ),
    );
  }

  /// Ajoute une notification de like au propriétaire du post
  ///
  /// COMPORTEMENT :
  /// - Vérifie que l'utilisateur qui like n'est pas le propriétaire
  /// - Récupère les infos de l'utilisateur qui like
  /// - Crée une notification dans Firestore avec :
  ///   * Type : "like"
  ///   * Username, userId, photo de profil
  ///   * PostId et mediaUrl du post
  ///   * Timestamp actuel
  addLikesToNotification() async {
    bool isNotMe = currentUserId() != widget.post!.ownerId;

    if (isNotMe) {
      DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
      user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
      notificationRef
          .doc(widget.post!.ownerId)
          .collection('notifications')
          .doc(widget.post!.postId)
          .set({
        "type": "like",
        "username": user!.username!,
        "userId": currentUserId(),
        "userDp": user!.photoUrl!,
        "postId": widget.post!.postId,
        "mediaUrl": widget.post!.mediaUrl,
        "timestamp": timestamp,
      });
    }
  }

  /// Supprime la notification de like du propriétaire du post
  ///
  /// COMPORTEMENT :
  /// - Vérifie que l'utilisateur qui unlike n'est pas le propriétaire
  /// - Récupère les infos de l'utilisateur
  /// - Supprime la notification correspondante de Firestore
  /// - Vérifie l'existence du document avant suppression
  removeLikeFromNotification() async {
    bool isNotMe = currentUserId() != widget.post!.ownerId;

    if (isNotMe) {
      DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
      user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
      notificationRef
          .doc(widget.post!.ownerId)
          .collection('notifications')
          .doc(widget.post!.postId)
          .get()
          .then((doc) => {
                if (doc.exists) {doc.reference.delete()}
              });
    }
  }
}
